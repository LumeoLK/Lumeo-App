from __future__ import annotations
import gc
import os
from pathlib import Path
import torch
from PIL import Image, ImageOps, ImageStat

BASE_MODEL_ID = os.getenv("LUMEO_SD15_MODEL", "runwayml/stable-diffusion-v1-5")
CONTROLNET_MODEL_ID = os.getenv("LUMEO_CONTROLNET_MODEL", "lllyasviel/control_v11p_sd15_lineart")

DEFAULT_PROMPT = (
    "photorealistic studio product render of a single furniture piece, "
    "realistic materials, soft shadows, white seamless background, "
    "centered composition, high detail, 3D render"
)
DEFAULT_NEGATIVE_PROMPT = (
    "blueprint, technical drawing, wireframe, sketch, line art, "
    "text, watermark, duplicate, cropped, low quality, blurry"
)

def _install_siglip_shims():
    import transformers
    missing = [
        "SiglipImageProcessor", "SiglipModel",
        "SiglipVisionConfig", "SiglipVisionModel",
    ]
    class _Stub:
        @classmethod
        def from_pretrained(cls, *a, **kw):
            raise ImportError("SigLIP not available in this transformers version.")
    for name in missing:
        if not hasattr(transformers, name):
            setattr(transformers, name, _Stub)

def _load_pipeline():
    _install_siglip_shims()
    from diffusers import ControlNetModel, StableDiffusionControlNetPipeline, UniPCMultistepScheduler
    return ControlNetModel, StableDiffusionControlNetPipeline, UniPCMultistepScheduler

def _prepare_control_image(blueprint_path: Path, size: int = 512) -> Image.Image:
    img = Image.open(blueprint_path).convert("L")
    img = ImageOps.autocontrast(img)
    if ImageStat.Stat(img).mean[0] < 127:
        img = ImageOps.invert(img)
    img.thumbnail((size, size), Image.Resampling.LANCZOS)
    canvas = Image.new("L", (size, size), 255)
    offset = ((size - img.width) // 2, (size - img.height) // 2)
    canvas.paste(img, offset)
    return canvas.convert("RGB")

def generate_image(
    blueprint_path: str | Path,
    output_dir: str | Path | None = None,
    prompt: str = DEFAULT_PROMPT,
    negative_prompt: str = DEFAULT_NEGATIVE_PROMPT,
) -> str:
    source_path = Path(blueprint_path).expanduser().resolve()
    if not source_path.exists():
        raise FileNotFoundError(f"Blueprint not found: {source_path}")

    if output_dir is None:
        output_root = Path(__file__).resolve().parent / "output" / source_path.stem
    else:
        output_root = Path(output_dir)
    output_root.mkdir(parents=True, exist_ok=True)
    output_path = output_root / "render.png"

    ControlNetModel, StableDiffusionControlNetPipeline, UniPCMultistepScheduler = _load_pipeline()

    use_cuda = torch.cuda.is_available()
    dtype = torch.float16 if use_cuda else torch.float32

    print("Loading ControlNet + Stable Diffusion v1.5...")
    controlnet = ControlNetModel.from_pretrained(
        CONTROLNET_MODEL_ID,
        torch_dtype=dtype,
        low_cpu_mem_usage=True,
    )
    pipe = StableDiffusionControlNetPipeline.from_pretrained(
        BASE_MODEL_ID,
        controlnet=controlnet,
        torch_dtype=dtype,
        safety_checker=None,
        requires_safety_checker=False,
        low_cpu_mem_usage=True,
    )
    pipe.scheduler = UniPCMultistepScheduler.from_config(pipe.scheduler.config)
    pipe.enable_attention_slicing("max")
    pipe.enable_vae_slicing()

    if use_cuda:
        pipe.enable_model_cpu_offload()
    else:
        pipe.to("cpu")

    control_image = _prepare_control_image(source_path)
    generator = torch.Generator(device="cpu").manual_seed(42)

    print("Generating realistic furniture render...")
    result = pipe(
        prompt=prompt,
        negative_prompt=negative_prompt,
        image=control_image,
        num_inference_steps=30,
        guidance_scale=7.5,
        controlnet_conditioning_scale=1.0,
        generator=generator,
    ).images[0]

    result.save(output_path)
    print(f"Render saved: {output_path}")

    del pipe, controlnet
    gc.collect()
    if use_cuda:
        torch.cuda.empty_cache()

    return str(output_path)