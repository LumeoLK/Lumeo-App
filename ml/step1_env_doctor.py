from __future__ import annotations

import argparse
import importlib.util
import os
import site
import sys
from pathlib import Path


REQUIRED_MARKERS = (
    Path("pyvenv.cfg"),
    Path("Scripts/python.exe"),
    Path("Scripts/pip.exe"),
)

STEP1_PACKAGES = ("torch", "diffusers", "transformers")


def resolve_site_packages(venv_path: Path) -> list[Path]:
    candidates = []

    for lib_dir in (venv_path / "Lib", venv_path / "lib"):
        if not lib_dir.exists():
            continue

        direct = lib_dir / "site-packages"
        if direct.exists():
            candidates.append(direct)

        for child in lib_dir.iterdir():
            nested = child / "site-packages"
            if nested.exists():
                candidates.append(nested)

    if not candidates:
        try:
            candidates = [Path(p) for p in site.getsitepackages() if "site-packages" in p]
        except AttributeError:
            candidates = []

    unique_candidates = []
    seen = set()
    for candidate in candidates:
        key = str(candidate.resolve()) if candidate.exists() else str(candidate)
        if key not in seen:
            seen.add(key)
            unique_candidates.append(candidate)

    return unique_candidates


def find_package_root(package_name: str, site_packages: list[Path]) -> Path | None:
    for site_packages_dir in site_packages:
        candidate = site_packages_dir / package_name
        if candidate.exists():
            return candidate
    return None


def import_spec_available(package_name: str) -> bool:
    return importlib.util.find_spec(package_name) is not None


def inspect_venv(venv_path: Path) -> tuple[list[str], list[str]]:
    issues: list[str] = []
    notes: list[str] = []

    for marker in REQUIRED_MARKERS:
        full_path = venv_path / marker
        if not full_path.exists():
            issues.append(f"Missing required venv file: {full_path}")

    site_packages = resolve_site_packages(venv_path)
    if not site_packages:
        issues.append(f"Could not locate site-packages under: {venv_path}")
        return issues, notes

    notes.append("site-packages searched:")
    notes.extend(f"  - {path}" for path in site_packages)

    for package_name in STEP1_PACKAGES:
        package_root = find_package_root(package_name, site_packages)
        if package_root is None:
            issues.append(f"Package folder missing from site-packages: {package_name}")
            continue

        init_file = package_root / "__init__.py"
        if not init_file.exists():
            issues.append(
                f"Package is incomplete for Step 1: {package_root} is missing __init__.py"
            )
        else:
            notes.append(f"Found package marker: {init_file}")

        if package_name in sys.modules:
            continue

        if not import_spec_available(package_name):
            issues.append(f"Python cannot resolve import for package: {package_name}")

    return issues, notes


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Validate that the Step 1 ControlNet environment is structurally intact."
    )
    parser.add_argument(
        "--venv",
        default="venv312",
        help="Path to the Step 1 virtual environment root.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    venv_path = Path(args.venv).resolve()

    print(f"Checking Step 1 environment: {venv_path}")

    if not venv_path.exists():
        print(f"ERROR: virtual environment path does not exist: {venv_path}")
        return 1

    issues, notes = inspect_venv(venv_path)

    for note in notes:
        print(note)

    if issues:
        print("")
        print("Step 1 environment is broken:")
        for issue in issues:
            print(f" - {issue}")
        print("")
        print("Recommended repair:")
        print(
            " - Run .\\repair_step1_venv.ps1 -VenvPath "
            f"\"{venv_path}\" -PythonCommand \"py -3.12\""
        )
        return 1

    print("")
    print("Step 1 environment looks healthy.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
