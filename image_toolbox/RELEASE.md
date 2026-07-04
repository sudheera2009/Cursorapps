# Release Checklist — Image Toolbox

This app is code-complete and passes `flutter analyze` and `flutter test`.
Building signed store artifacts requires a full local toolchain (Android SDK /
Xcode), which is **not** available in the cloud dev environment. Follow this
checklist on a developer machine.

## 1. Branding & identifiers

- [x] App name: **Image Toolbox** (Android label + iOS `CFBundleDisplayName`)
- [x] Android `applicationId`: `com.toolboxlab.image_toolbox`
- [ ] iOS bundle id: set in Xcode (`PRODUCT_BUNDLE_IDENTIFIER`)
- [x] Launcher icon + adaptive icon + native splash generated
- [ ] Bump `version:` in `pubspec.yaml` for each release

## 2. Monetization (AdMob)

The app currently uses **Google test ad unit ids**. Before release:

- [ ] Create a real AdMob app + ad units (banner, interstitial, rewarded)
- [ ] Replace ids in `lib/services/ad_service.dart`
- [ ] Replace the AdMob **app id** in:
  - `android/app/src/main/AndroidManifest.xml` (`com.google.android.gms.ads.APPLICATION_ID`)
  - `ios/Runner/Info.plist` (`GADApplicationIdentifier`)
- [ ] Update `SKAdNetworkItems` in `Info.plist` with your ad partners' ids

## 3. Android signing

```bash
keytool -genkey -v -keystore ~/image-toolbox-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

- [ ] Copy `android/key.properties.example` → `android/key.properties` and fill in
- [ ] `flutter build appbundle --release`
- [ ] Verify signing: the release build uses `key.properties` automatically

## 4. iOS signing & build

- [ ] Open `ios/Runner.xcworkspace`, set team & bundle id
- [ ] Confirm usage strings (photos, camera, tracking) read well
- [ ] `flutter build ipa --release`

## 5. Store listings

- [ ] Use `store_listing.md` for titles, descriptions and keywords
- [ ] Screenshots (phone + tablet), feature graphic (Play)
- [ ] Privacy policy URL (host `PRIVACY_POLICY.md`)
- [ ] Data safety / App privacy questionnaires:
  - Images: processed on-device, not collected
  - Ads: device identifiers via AdMob

## 6. Pre-flight QA

- [ ] `flutter analyze` → no issues
- [ ] `flutter test` → all pass
- [ ] Manual: compress (quality + target KB), resize (all modes), convert
      (JPEG/PNG/WebP), crop & rotate, filters/adjust, watermark, batch of 10+,
      Save all, Export ZIP
- [ ] Permission denial paths behave gracefully
