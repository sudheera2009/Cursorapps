# Image Toolbox 🧰🖼️

**All your image tools, in one offline app.** Compress, resize, convert, crop,
rotate, filter and watermark photos — one at a time or in batches — without ever
uploading them anywhere. Every pixel is processed on-device.

> Part of the `cursor apps` Flutter monorepo. This is the **PR 1 / MVP** build.

---

## ✨ Features (MVP)

| Tool | What it does |
| --- | --- |
| 🗜️ **Compress** | Reduce file size by quality or an exact **target KB** (auto-tuned), optionally capping dimensions. |
| 📐 **Resize** | By percentage, exact width/height, or "max longest side" with handy presets (512–3840). |
| 🔄 **Convert** | JPEG ⇄ PNG ⇄ WebP. Transparency is flattened for JPEG. |
| ✂️ **Crop & Rotate** | Interactive crop, straighten, rotate and flip (via native cropper). |
| 🎨 **Filters & Adjust** | Presets (Mono, Sepia, Vintage, Vivid, Cool, Warm, Invert) plus brightness / contrast / saturation / sharpen. |
| 💧 **Watermark** | Stamp text with position, opacity and tiling across one or many images. |
| ⚡ **Recipes** | One-tap presets (Web Ready, Email Small, Instagram Square, Tiny Thumbnail) — reusable pipelines. |
| 🧺 **Batch** | Run any tool over many images at once, then **Save all** or **Export ZIP**. |
| 📊 **Stats** | Lifetime "space saved" dashboard, computed locally. |

## 🔒 Privacy

Image Toolbox performs **100% on-device processing**. Photos are never uploaded
to a server. See [`PRIVACY_POLICY.md`](PRIVACY_POLICY.md).

---

## 🏗️ Architecture

```
lib/
├── core/            # theme, formatters
├── models/          # EditOp (sealed, JSON), EncodeSettings, Recipe,
│                    #   ImageJob, ProcessResult, Tool registry, enums
├── pipeline/        # pure-Dart engine (isolate) + async wrapper
├── providers/       # SettingsProvider, JobsProvider, RecipesProvider
├── services/        # picker, gallery, export (share/zip), ads
├── widgets/         # GlassCard, BeforeAfterSlider, ToolCard, banner
└── screens/         # splash, onboarding, hub, configure, processing,
                     #   result, batch result, recipes, dashboard, settings
```

### The pipeline

The heart of the app is a **pure-Dart, isolate-friendly pipeline**
(`pipeline/pipeline_runner.dart`). A list of serializable `EditOp`s
(resize / crop / rotate / filter / adjust / watermark / round-corners) plus an
`EncodeSettings` object is sent to a background isolate via `compute()`, keeping
the UI at 60fps even on large images.

- **JPEG / PNG** are encoded entirely in Dart (fully unit-tested).
- **JPEG target-size** uses a binary search over quality, then progressive
  downscaling if it still can't fit.
- **WebP** output is finished with the native `flutter_image_compress` codec
  (WebP encoding isn't available in pure Dart), falling back to PNG if needed.

Because the ops are JSON-serializable, the exact same pipeline powers **Recipes**
(saved, reusable op-chains) and **Batch** processing.

## 🧪 Testing

```bash
flutter test
```

13 unit tests cover resize/crop/rotate, JPEG/PNG encoding, target-size search,
alpha handling, and full `EditOp` / `Recipe` JSON round-trips — all runnable
without a device.

## ▶️ Running

```bash
flutter pub get
flutter run
```

Regenerate icons/splash after changing `assets/icon/`:

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

## 📦 Releasing

See [`RELEASE.md`](RELEASE.md) for the full store checklist (production AdMob ids,
signing, app bundle / IPA, listings).

## ⚙️ Known build warning

`flutter_image_compress` still applies the legacy Kotlin Gradle Plugin, so a
build prints a KGP deprecation warning. It is harmless with the current Flutter
version and will be resolved upstream; nothing to do on our side today.

## 🗺️ Roadmap (post-MVP)

- Layered editor canvas (freeform text/stickers/draw)
- Background removal & selfie segmentation (on-device ML)
- OCR / text extraction, EXIF viewer/editor
- PDF ⇄ image, collage/grid maker

_Done since the first MVP:_ live processed preview, save-as-recipe from any
configure screen, WebP target-size auto-tuning, EXIF preservation, and
camera-permission UX.
