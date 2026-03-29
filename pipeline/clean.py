from __future__ import annotations
from io import BytesIO
from pathlib import Path
from PIL import Image
from rembg import new_session, remove

_REMBG_SESSION = None

def _get_rembg_session():
    global _REMBG_SESSION
    if _REMBG_SESSION is None:
        _REMBG_SESSION = new_session()
    return _REMBG_SESSION

def clean_image(input_path: str | Path, output_dir: str | Path | None = None) -> str:
    source_path = Path(input_path).expanduser().resolve()
    if not source_path.exists():
        raise FileNotFoundError(f"Rendered image not found: {source_path}")

    if output_dir is None:
        output_root = source_path.parent
    else:
        output_root = Path(output_dir)
    output_root.mkdir(parents=True, exist_ok=True)

    output_path = output_root / "clean.png"

    image = Image.open(source_path).convert("RGBA")
    result = remove(image, session=_get_rembg_session())

    if isinstance(result, bytes):
        result = Image.open(BytesIO(result)).convert("RGBA")
    else:
        result = result.convert("RGBA")

    background = Image.new("RGBA", result.size, (255, 255, 255, 255))
    background.alpha_composite(result)
    final = background.convert("RGB")
    final.save(output_path)

    print(f"Cleaned image saved: {output_path}")
    return str(output_path)