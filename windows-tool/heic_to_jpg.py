"""
HEIC to JPG converter — preserves full EXIF metadata (date, GPS, camera info).
Usage: heic_to_jpg.exe file1.heic [file2.heic ...]
"""

import sys
import os
from pathlib import Path


def show_error(message: str) -> None:
    try:
        import ctypes
        ctypes.windll.user32.MessageBoxW(0, message, "HEIC to JPG — Error", 0x10)
    except Exception:
        pass


def convert(heic_path: Path) -> Path:
    import pillow_heif
    from PIL import Image

    pillow_heif.register_heif_opener()

    jpg_path = heic_path.with_suffix(".jpg")
    counter = 1
    while jpg_path.exists():
        jpg_path = heic_path.with_name(f"{heic_path.stem}_{counter}.jpg")
        counter += 1

    img = Image.open(heic_path)
    exif = img.info.get("exif")

    if img.mode != "RGB":
        img = img.convert("RGB")

    save_kwargs: dict = {"quality": 95, "optimize": True}
    if exif:
        save_kwargs["exif"] = exif

    img.save(jpg_path, "JPEG", **save_kwargs)
    return jpg_path


def main() -> None:
    paths = sys.argv[1:]
    if not paths:
        show_error("No file provided.\n\nRight-click a .heic file and choose 'Convert to JPG'.")
        sys.exit(1)

    errors: list[str] = []

    for raw in paths:
        p = Path(raw)
        try:
            convert(p)
        except Exception as exc:
            errors.append(f"{p.name}: {exc}")

    if errors:
        show_error("Conversion failed:\n\n" + "\n".join(errors))
        sys.exit(1)


if __name__ == "__main__":
    main()
