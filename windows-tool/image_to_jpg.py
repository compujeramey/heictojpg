"""
Image to JPG converter — preserves EXIF metadata (date, GPS, camera info)
where present. Supports HEIC/HEIF, WEBP, PNG, and PDF source files.
Each page of a PDF is saved as its own JPG.
Usage: image_to_jpg.exe file1.heic [file2.webp file3.png file4.pdf ...]
"""

import sys
from pathlib import Path

HEIF_SUFFIXES = {".heic", ".heif"}
PDF_RENDER_DPI = 200


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


def main() -> None:
    paths = sys.argv[1:]
    if not paths:
        show_error(
            "No file provided.\n\n"
            "Right-click a .heic, .heif, .webp, .png, or .pdf file and choose 'Convert to JPG'."
        )
        sys.exit(1)

    errors: list[str] = []

    for raw in paths:
        p = Path(raw)
        try:
            if p.suffix.lower() == ".pdf":
                convert_pdf(p)
            else:
                convert(p)
        except Exception as exc:
            errors.append(f"{p.name}: {exc}")

    if errors:
        show_error("Conversion failed:\n\n" + "\n".join(errors))
        sys.exit(1)


if __name__ == "__main__":
    main()
