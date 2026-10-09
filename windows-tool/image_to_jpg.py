"""
Image to JPG converter — preserves EXIF metadata (date, GPS, camera info)
where present. Supports HEIC/HEIF, WEBP, PNG, and PDF source files.
Each page of a PDF is saved as its own JPG.
Usage: image_to_jpg.exe file1.heic [file2.webp file3.png file4.pdf ...]

When several files are selected in Explorer, Windows launches one process per
file. Those processes coordinate through a lock file and a queue directory in
%TEMP%: the first to grab the lock becomes the leader and converts every queued
file; the rest just enqueue their paths and exit. This yields a single combined
error report for the whole batch.
"""

import os
import sys
import tempfile
import time
import uuid
from pathlib import Path

HEIF_SUFFIXES = {".heic", ".heif"}
PDF_RENDER_DPI = 200

WORK_DIR = Path(tempfile.gettempdir()) / "ImageToJPG"
QUEUE_DIR = WORK_DIR / "queue"
LOCK_PATH = WORK_DIR / "leader.lock"
# How long the leader keeps waiting for stragglers once the queue is empty.
QUIET_PERIOD_SECONDS = 1.5


def show_error(message: str) -> None:
    try:
        import ctypes
        ctypes.windll.user32.MessageBoxW(0, message, "Image to JPG — Error", 0x10)
    except Exception:
        pass


def unique_path(candidate: Path) -> Path:
    counter = 1
    while candidate.exists():
        candidate = candidate.with_name(f"{candidate.stem}_{counter}{candidate.suffix}")
        counter += 1
    return candidate


def convert_pdf(src_path: Path) -> list[Path]:
    import fitz  # PyMuPDF
    from PIL import Image

    doc = fitz.open(src_path)
    zoom = PDF_RENDER_DPI / 72
    matrix = fitz.Matrix(zoom, zoom)

    out_paths = []
    for page_index, page in enumerate(doc, start=1):
        pix = page.get_pixmap(matrix=matrix, alpha=False)
        img = Image.frombytes("RGB", (pix.width, pix.height), pix.samples)

        if len(doc) == 1:
            jpg_path = unique_path(src_path.with_suffix(".jpg"))
        else:
            jpg_path = unique_path(src_path.with_name(f"{src_path.stem}_p{page_index}.jpg"))

        img.save(jpg_path, "JPEG", quality=95, optimize=True)
        out_paths.append(jpg_path)

    doc.close()
    return out_paths


def convert(src_path: Path) -> Path:
    from PIL import Image

    if src_path.suffix.lower() in HEIF_SUFFIXES:
        import pillow_heif
        pillow_heif.register_heif_opener()

    jpg_path = unique_path(src_path.with_suffix(".jpg"))

    img = Image.open(src_path)
    exif = img.info.get("exif")

    if img.mode in ("RGBA", "LA", "P"):
        # Flatten transparency onto a white background — JPEG has no alpha channel.
        rgba = img.convert("RGBA")
        background = Image.new("RGB", rgba.size, (255, 255, 255))
        background.paste(rgba, mask=rgba.split()[-1])
        img = background
    elif img.mode != "RGB":
        img = img.convert("RGB")

    save_kwargs: dict = {"quality": 95, "optimize": True}
    if exif:
        save_kwargs["exif"] = exif

    img.save(jpg_path, "JPEG", **save_kwargs)
    return jpg_path


def convert_any(p: Path) -> None:
    if p.suffix.lower() == ".pdf":
        convert_pdf(p)
    else:
        convert(p)


def enqueue(paths: list[str]) -> None:
    QUEUE_DIR.mkdir(parents=True, exist_ok=True)
    name = uuid.uuid4().hex
    tmp = QUEUE_DIR / f"{name}.tmp"
    tmp.write_text("\n".join(str(Path(p).resolve()) for p in paths), encoding="utf-8")
    # Rename is atomic, so the leader never reads a half-written entry.
    os.replace(tmp, QUEUE_DIR / f"{name}.txt")


def drain_queue() -> list[Path]:
    paths: list[Path] = []
    for entry in sorted(QUEUE_DIR.glob("*.txt")):
        try:
            text = entry.read_text(encoding="utf-8")
            entry.unlink()
        except OSError:
            continue
        paths.extend(Path(line) for line in text.splitlines() if line)
    return paths


def try_lock():
    """Non-blocking exclusive lock on LOCK_PATH. Returns the open file, or None."""
    WORK_DIR.mkdir(parents=True, exist_ok=True)
    fh = open(LOCK_PATH, "a+b")
    try:
        if sys.platform == "win32":
            import msvcrt
            fh.seek(0)
            msvcrt.locking(fh.fileno(), msvcrt.LK_NBLCK, 1)
        else:
            import fcntl
            fcntl.flock(fh.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)
    except OSError:
        fh.close()
        return None
    return fh


def unlock(fh) -> None:
    if sys.platform == "win32":
        import msvcrt
        fh.seek(0)
        msvcrt.locking(fh.fileno(), msvcrt.LK_UNLCK, 1)
    else:
        import fcntl
        fcntl.flock(fh.fileno(), fcntl.LOCK_UN)
    fh.close()


def run_as_leader(lock) -> list[str]:
    errors: list[str] = []
    seen: set[Path] = set()

    while True:
        idle_since = time.monotonic()
        while time.monotonic() - idle_since < QUIET_PERIOD_SECONDS:
            batch = drain_queue()
            if not batch:
                time.sleep(0.1)
                continue
            for p in batch:
                if p in seen:
                    continue
                seen.add(p)
                try:
                    convert_any(p)
                except Exception as exc:
                    errors.append(f"{p.name}: {exc}")
            idle_since = time.monotonic()

        # Release, then re-check. A follower that enqueued after this check
        # will find the lock free and become the next leader, so nothing is lost.
        unlock(lock)
        if not any(QUEUE_DIR.glob("*.txt")):
            return errors
        lock = try_lock()
        if lock is None:
            return errors


def main() -> None:
    paths = sys.argv[1:]
    if not paths:
        show_error(
            "No file provided.\n\n"
            "Right-click a .heic, .heif, .webp, .png, or .pdf file and choose 'Convert to JPG'."
        )
        sys.exit(1)

    enqueue(paths)
    lock = try_lock()
    if lock is None:
        # Another instance is already converting; it will pick up our files.
        return

    errors = run_as_leader(lock)
    if errors:
        show_error("Conversion failed:\n\n" + "\n".join(errors))
        sys.exit(1)


if __name__ == "__main__":
    main()
