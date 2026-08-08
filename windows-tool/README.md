# Image to JPG — Windows Right-Click Converter

Converts `.heic` / `.heif` / `.webp` / `.png` / `.pdf` files to JPG directly from the Windows Explorer right-click menu. Preserves EXIF metadata (date taken, GPS location, camera make/model, orientation) where the source file has it. PDFs are rendered page-by-page into one JPG per page.

## Getting the installer

### Option A — GitHub Releases (recommended)

1. Push a version tag to trigger the build:
   ```
   git tag v2.0 && git push origin v2.0
   ```
2. GitHub Actions builds the installer on a Windows runner automatically.
3. Download `ImageToJPG-Setup.exe` from the **Releases** page.
4. Run it (requires admin). Done.

You can also trigger a build manually from the **Actions** tab using **Run workflow** without creating a tag — the exe will be available as a downloadable artifact.

### Option B — Build locally on Windows

If you have Python 3.10+ installed:

```
build.bat
```

Then run `install.bat` as Administrator.

## Usage

Right-click any `.heic`, `.heif`, `.webp`, `.png`, or `.pdf` file in Explorer → **Convert to JPG**.

The `.jpg` is saved in the same folder. If a file with that name already exists, a counter suffix is added (`photo_1.jpg`, `photo_2.jpg`, …).

PNG and WEBP images with transparency are flattened onto a white background, since JPEG has no alpha channel.

For a PDF, each page is rendered at 200 DPI and saved as its own JPG: a single-page PDF becomes `document.jpg`, a multi-page PDF becomes `document_p1.jpg`, `document_p2.jpg`, etc.

## Uninstall

Use **Add or remove programs** → search for "Image to JPG Converter" → Uninstall.

## Metadata preserved

| Field | Notes |
|---|---|
| Date taken | `DateTimeOriginal`, when present in the source file |
| GPS coordinates | Latitude, longitude, altitude |
| Camera make / model | e.g. `Apple iPhone 15 Pro` |
| Orientation | Rotated correctly in the output |
| Exposure, aperture, ISO | Full EXIF block passed through |

Note: plain `.png` files rarely carry EXIF data (it's not part of the PNG spec), so there's usually nothing to preserve for those.
