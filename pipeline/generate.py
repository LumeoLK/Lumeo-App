from __future__ import annotations
import shutil
from pathlib import Path


def generate_image(
    blueprint_path: str | Path,
    output_dir: str | Path | None = None,
) -> str:
    from gradio_client import Client

    source_path = Path(blueprint_path).expanduser().resolve()
    if not source_path.exists():
        raise FileNotFoundError(f"Blueprint not found: {source_path}")

    if output_dir is None:
        output_root = Path(__file__).resolve().parent / "output" / source_path.stem
    else:
        output_root = Path(output_dir)
    output_root.mkdir(parents=True, exist_ok=True)
    output_path = output_root / "render.png"

    print("Calling Hugging Face space for blueprint → image...")
    client = Client("InduwaraDilshan/Blueprint-to-3d-Demo")
    result = client.predict(
        str(source_path),
        api_name="/predict"
    )

    shutil.copy(result, output_path)
    print(f"Render saved: {output_path}")
    return str(output_path)


if __name__ == "__main__":
    import sys
    blueprint = sys.argv[1] if len(sys.argv) > 1 else "test.png"
    result = generate_image(blueprint)
    print(f"Result: {result}")