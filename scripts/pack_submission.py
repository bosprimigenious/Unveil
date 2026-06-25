#!/usr/bin/env python3
"""Pack course submission: DOCX report + source-only RAR (no .typ, no build artifacts)."""
from __future__ import annotations

import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BASE_NAME = "2024210926-张恒基-2024210940-秦博宇-2024210959-陈艺博-2024211005-陈雨飞"
SUBMIT_DIR = ROOT / "submission"
STAGE_DIR = SUBMIT_DIR / "stage"
DOCX_PATH = SUBMIT_DIR / f"{BASE_NAME}.docx"
RAR_PATH = SUBMIT_DIR / f"{BASE_NAME}.rar"
PDF_PATH = ROOT / "docs" / "FINAL" / "FINAL_REPORT.pdf"

EXCLUDE_DIRS = {
    "target",
    "bin",
    "node_modules",
    "dist",
    "build",
    ".git",
    ".idea",
    ".claude",
    ".cursor",
    ".vscode",
    ".vite",
    "records",
    "submission",
}

EXCLUDE_FILE_SUFFIXES = {
    ".class",
    ".jar",
    ".war",
    ".log",
    ".iml",
    ".typ",
    ".pdf",
}

EXCLUDE_FILE_NAMES = {
    "Thumbs.db",
    ".DS_Store",
    "dependency-reduced-pom.xml",
}


def convert_pdf_to_docx() -> None:
    if not PDF_PATH.is_file():
        raise FileNotFoundError(f"Report PDF not found: {PDF_PATH}")
    SUBMIT_DIR.mkdir(parents=True, exist_ok=True)
    from pdf2docx import Converter

    print(f"Converting {PDF_PATH.name} -> {DOCX_PATH.name} ...")
    cv = Converter(str(PDF_PATH))
    cv.convert(str(DOCX_PATH), start=0, end=None)
    cv.close()
    print(f"DOCX saved: {DOCX_PATH}")


def should_skip(path: Path) -> bool:
    if path.name in EXCLUDE_FILE_NAMES:
        return True
    if path.suffix.lower() in EXCLUDE_FILE_SUFFIXES:
        return True
    return False


def ignore_patterns(_dir: str, names: list[str]) -> set[str]:
    ignored: set[str] = set()
    for name in names:
        if name in EXCLUDE_DIRS or name in EXCLUDE_FILE_NAMES:
            ignored.add(name)
            continue
        suffix = Path(name).suffix.lower()
        if suffix in EXCLUDE_FILE_SUFFIXES:
            ignored.add(name)
    return ignored


def stage_sources() -> None:
    if STAGE_DIR.exists():
        shutil.rmtree(STAGE_DIR)
    STAGE_DIR.mkdir(parents=True, exist_ok=True)

    print("Staging source files ...")
    for item in ROOT.iterdir():
        if item.name in EXCLUDE_DIRS:
            continue
        dest = STAGE_DIR / item.name
        if item.is_dir():
            shutil.copytree(item, dest, ignore=ignore_patterns, dirs_exist_ok=True)
        elif item.is_file() and not should_skip(item):
            shutil.copy2(item, dest)


def find_rar_exe() -> Path | None:
    candidates = [
        Path(r"C:\Program Files\WinRAR\Rar.exe"),
        Path(r"C:\Program Files (x86)\WinRAR\Rar.exe"),
    ]
    for path in candidates:
        if path.is_file():
            return path
    for name in ("Rar.exe", "rar.exe"):
        found = shutil.which(name)
        if found:
            return Path(found)
    return None


def create_rar() -> None:
    rar_exe = find_rar_exe()
    if rar_exe is None:
        raise FileNotFoundError("WinRAR not found; install WinRAR or add Rar.exe to PATH")
    if RAR_PATH.exists():
        RAR_PATH.unlink()
    print(f"Creating {RAR_PATH.name} ...")
    subprocess.run(
        [str(rar_exe), "a", "-r", "-ep1", str(RAR_PATH), "*"],
        cwd=STAGE_DIR,
        check=True,
    )
    print(f"RAR saved: {RAR_PATH}")


def use_docx(src: Path) -> None:
    if not src.is_file():
        raise FileNotFoundError(f"DOCX not found: {src}")
    SUBMIT_DIR.mkdir(parents=True, exist_ok=True)
    src = src.resolve()
    if src != DOCX_PATH.resolve():
        shutil.copy2(src, DOCX_PATH)
        print(f"Using DOCX: {src.name} -> {DOCX_PATH.name}")
    else:
        print(f"Using DOCX: {DOCX_PATH.name}")


def main() -> int:
    import argparse

    parser = argparse.ArgumentParser(description="Pack course submission (DOCX + source RAR)")
    parser.add_argument(
        "--docx",
        type=Path,
        help="Use this Word file instead of converting from PDF",
    )
    parser.add_argument(
        "--skip-convert",
        action="store_true",
        help="Keep existing DOCX at output path; skip PDF conversion",
    )
    args = parser.parse_args()

    if args.docx:
        use_docx(args.docx.resolve())
    elif args.skip_convert:
        if not DOCX_PATH.is_file():
            raise FileNotFoundError(f"No existing DOCX at {DOCX_PATH}; omit --skip-convert or pass --docx")
        print(f"Keeping existing DOCX: {DOCX_PATH.name}")
    else:
        convert_pdf_to_docx()

    stage_sources()
    create_rar()
    for path in (DOCX_PATH, RAR_PATH):
        size_mb = path.stat().st_size / (1024 * 1024)
        print(f"{path.name}: {size_mb:.2f} MB")
    return 0


if __name__ == "__main__":
    sys.exit(main())
