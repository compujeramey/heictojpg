# HEIC to JPG — Windows Right-Click Converter

Converts `.heic` / `.heif` files to JPG directly from the Windows Explorer right-click menu. Preserves all EXIF metadata: date taken, GPS location, camera make/model, orientation, and more.

## Getting the installer

### Option A — GitHub Releases (recommended)

1. Push a version tag to trigger the build:
   ```
   git tag v1.0 && git push origin v1.0
   ```
2. GitHub Actions builds the installer on a Windows runner automatically.
3. Download `HEICtoJPG-Setup.exe` from the **Releases** page.
4. Run it (requires admin). Done.

You can also trigger a build manually from the **Actions** tab using **Run workflow** without creating a tag — the exe will be available as a downloadable artifact.

### Option B — Build locally on Windows

If you have Python 3.10+ installed:

```
build.bat
```

Then run `install.bat` as Administrator.

## Usage

Right-click any `.heic` or `.heif` file in Explorer → **Convert to JPG**.

The `.jpg` is saved in the same folder. If a file with that name already exists, a counter suffix is added (`photo_1.jpg`, `photo_2.jpg`, …).

## Uninstall

Use **Add or remove programs** → search for "HEIC to JPG Converter" → Uninstall.

## Metadata preserved

| Field | Notes |
|---|---|
| Date taken | `DateTimeOriginal` |
| GPS coordinates | Latitude, longitude, altitude |
| Camera make / model | e.g. `Apple iPhone 15 Pro` |
| Orientation | Rotated correctly in the output |
| Exposure, aperture, ISO | Full EXIF block passed through |
