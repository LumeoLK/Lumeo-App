from __future__ import annotations
import sys
from pathlib import Path
from generate import generate_image
from clean import clean_image
from triposr_run import run_triposr

def full_pipeline(blueprint_path: str | Path) -> str:
    source_path = Path(blueprint_path).expanduser().resolve()
    if not source_path.exists():
        raise FileNotFoundError(f"Blueprint not found: {source_path}")

    output_dir = Path(__file__).resolve().parent / "output" / source_path.stem
    output_dir.mkdir(parents=True, exist_ok=True)

    print("=" * 50)
    print("STEP 1: Generating realistic image from blueprint...")
    render_path = generate_image(source_path, output_dir=output_dir)

    print("=" * 50)
    print("STEP 2: Removing background...")
    clean_path = clean_image(render_path, output_dir=output_dir)

    print("=" * 50)
    print("STEP 3: Generating 3D model with TripoSR...")
    model_path = run_triposr(clean_path, output_dir=output_dir)

    print("=" * 50)
    print(f"DONE! 3D model saved at: {model_path}")
    return model_path

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python pipeline.py <blueprint_image.png>")
        sys.exit(1)
    result = full_pipeline(sys.argv[1])
    print(f"Final output: {result}")