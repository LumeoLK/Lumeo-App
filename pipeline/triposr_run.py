from __future__ import annotations
import os
import subprocess
import sys
from pathlib import Path

def run_triposr(image_path: str | Path, output_dir: str | Path | None = None) -> str:
    source_path = Path(image_path).expanduser().resolve()
    if not source_path.exists():
        raise FileNotFoundError(f"Clean image not found: {source_path}")

    pipeline_root = Path(__file__).resolve().parent
    triposr_root = pipeline_root / "triposr"
    triposr_entrypoint = triposr_root / "run.py"

    if not triposr_entrypoint.exists():
        raise FileNotFoundError(f"TripoSR entrypoint not found: {triposr_entrypoint}")

    if output_dir is None:
        output_root = source_path.parent / "triposr_output"
    else:
        output_root = Path(output_dir) / "triposr_output"
    output_root.mkdir(parents=True, exist_ok=True)

    env = os.environ.copy()
    existing = env.get("PYTHONPATH", "")
    env["PYTHONPATH"] = str(triposr_root) if not existing else f"{triposr_root}{os.pathsep}{existing}"

    command = [
        sys.executable,
        str(triposr_entrypoint),
        str(source_path),
        "--output-dir", str(output_root),
        "--model-save-format", "glb",
        "--chunk-size", "4096",
        "--no-remove-bg",
    ]

    print(f"Running TripoSR on: {source_path}")
    subprocess.run(command, cwd=str(triposr_root), env=env, check=True)

    for f in sorted(output_root.rglob("*.glb")):
        print(f"3D model saved: {f}")
        return str(f)

    for f in sorted(output_root.rglob("*.obj")):
        print(f"3D model saved: {f}")
        return str(f)

    raise FileNotFoundError(f"TripoSR did not generate a model in {output_root}")

if __name__ == "__main__":
    import sys
    image = sys.argv[1] if len(sys.argv) > 1 else "furniture.png"
    result = run_triposr(image)
    print(f"Result: {result}")