#!/usr/bin/env python3
"""Package Unveil submission: Word report + source-only RAR (no .typ, no build artifacts)."""
from __future__ import annotations

import os
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SUBMIT_DIR = ROOT / "submission"
BASE_NAME = "2024211301-张恒基-2024210940-秦博宇-2024210931-陈艺博-2024211005-陈雨飞"
PDF_SRC = ROOT / "docs" / "FINAL" / "FINAL_REPORT.pdf"
DOCX_OUT = SUBMIT_DIR / f"{BASE_NAME}.docx"
RAR_OUT = SUBMIT_DIR / f"{BASE_NAME}.rar"
STAGING = SUBMIT_DIR / "_source_staging"

EXCLUDE_DIR_NAMES = {
    ".git",
    ".claude",
    ".cursor",
    ".idea",
    ".vscode",
    "target",
    "bin",
    "node_modules",
    "dist",
    "build",
    "records",
    "submission",
    "__pycache__",
    ".mvn",
}

EXCLUDE_FILE_SUFFIXES = {
    ".class",
    ".jar",
    ".war",
    ".log",
    ".iml",
    ".typ",
    ".exe",
    ".dll",
    ".so",
    ".dylib",
    ".o",
    ".obj",
}

EXCLUDE_FILE_NAMES = {
    ".classpath",
    ".project",
    "dependency-reduced-pom.xml",
    "Thumbs.db",
    ".DS_Store",
}


def find_rar_exe() -> Path | None:
    candidates = [
        Path(r"C:\Program Files\WinRAR\Rar.exe"),
        Path(r"C:\Program Files\WinRAR\WinRAR.exe"),
        Path(r"C:\Program Files (x86)\WinRAR\Rar.exe"),
        Path(r"C:\Program Files (x86)\WinRAR\WinRAR.exe"),
    ]
    for path in candidates:
        if path.exists():
            return path
    for name in ("Rar.exe", "WinRAR.exe", "rar.exe"):
        found = shutil.which(name)
        if found:
            return Path(found)
    return None


def convert_pdf_to_docx() -> None:
    if not PDF_SRC.exists():
        raise FileNotFoundError(f"Report PDF not found: {PDF_SRC}")
    SUBMIT_DIR.mkdir(parents=True, exist_ok=True)
    print(f"Converting PDF -> DOCX: {DOCX_OUT.name}")
    from pdf2docx import Converter

    cv = Converter(str(PDF_SRC))
    try:
        cv.convert(str(DOCX_OUT), start=0, end=None)
    finally:
        cv.close()
    if not DOCX_OUT.exists() or DOCX_OUT.stat().st_size < 10_000:
        raise RuntimeError("DOCX conversion failed or output too small")


def should_skip_file(path: Path) -> bool:
    if path.name in EXCLUDE_FILE_NAMES:
        return True
    if path.suffix.lower() in EXCLUDE_FILE_SUFFIXES:
        return True
    return False


def should_skip_dir(name: str) -> bool:
    return name in EXCLUDE_DIR_NAMES


def copy_source_tree() -> None:
    if STAGING.exists():
        shutil.rmtree(STAGING)
    STAGING.mkdir(parents=True)

    copied = 0
    skipped = 0
    for dirpath, dirnames, filenames in os.walk(ROOT):
        dirnames[:] = [d for d in dirnames if not should_skip_dir(d)]
        rel_dir = Path(dirpath).relative_to(ROOT)
        if rel_dir.parts and rel_dir.parts[0] == "submission":
            continue

        for filename in filenames:
            src = Path(dirpath) / filename
            rel = src.relative_to(ROOT)
            if should_skip_file(src):
                skipped += 1
                continue
            dst = STAGING / rel
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src, dst)
            copied += 1

    print(f"Staged source files: {copied} copied, {skipped} skipped")


def create_rar(rar_exe: Path) -> None:
    if RAR_OUT.exists():
        RAR_OUT.unlink()
    cmd = [
        str(rar_exe),
        "a",
        "-r",
        "-m5",
        "-ep1",
        str(RAR_OUT),
        str(STAGING),
    ]
    print("Creating RAR archive...")
    result = subprocess.run(cmd, capture_output=True, text=True, cwd=STAGING)
    if result.returncode != 0:
        print(result.stdout)
        print(result.stderr, file=sys.stderr)
        raise RuntimeError(f"RAR failed with exit code {result.returncode}")
    if not RAR_OUT.exists():
        raise RuntimeError("RAR archive was not created")


def main() -> int:
    SUBMIT_DIR.mkdir(parents=True, exist_ok=True)
    copy_source_tree()

    rar_exe = find_rar_exe()
    if rar_exe is None:
        zip_out = SUBMIT_DIR / f"{BASE_NAME}.zip"
        if zip_out.exists():
            zip_out.unlink()
        print("WinRAR not found; falling back to ZIP (install WinRAR for .rar)")
        shutil.make_archive(str(zip_out.with_suffix("")), "zip", STAGING)
        print(f"ZIP created: {zip_out}")
        return 1

    create_rar(rar_exe)
    shutil.rmtree(STAGING, ignore_errors=True)
    print(f"RAR: {RAR_OUT.resolve()} ({RAR_OUT.stat().st_size // 1024} KB)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
