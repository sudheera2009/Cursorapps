# 🚀 AURA METER — Release Checklist

This document tracks everything required to publish AURA METER to the Google
Play Store and Apple App Store. Items marked ✅ are already done in this repo.
Items marked ⬜ require your accounts / keys / a machine with the mobile
toolchains and must be completed before shipping.

## 1. App configuration
- ✅ App name: **Aura Meter** (Android label + iOS `CFBundleDisplayName`)
- ✅ Bundle / application id: `com.auraverse.aura_meter`
- ✅ Branded launcher icon + adaptive icon (`assets/icon/`, generated)
- ✅ Native splash screen (light + Android 12 + dark)
- ✅ Version `1.0.0+1` in `pubspec.yaml` (bump build number on every upload)
- ⬜ Confirm the bundle id is unique/available on both stores (cannot be changed
  after first publish)

## 2. Ads (AdMob)
- ✅ `google_mobile_ads` integrated (banner, interstitial, rewarded)
- ✅ Interstitials shown on a soft cadence (every 3rd scan), rewarded ads for
  "2× aura" and "free aura"
- ⬜ Create an AdMob account + app + ad units, then replace **test** IDs with
  production IDs in:
  - `lib/services/ad_service.dart` (banner / interstitial / rewarded unit IDs)
  - `android/app/src/main/AndroidManifest.xml` (`APPLICATION_ID`)
  - `ios/Runner/Info.plist` (`GADApplicationIdentifier`)

## 3. Privacy & tracking
- ✅ In-app "entertainment only / not a real reading" disclaimer
- ✅ iOS `NSUserTrackingUsageDescription` + `SKAdNetworkItems` in `Info.plist`
- ⬜ Host `PRIVACY_POLICY.md` at a public URL and add it to both store listings
- ⬜ Complete Play **Data safety** form + App Store **App Privacy** nutrition labels
  (declare AdMob: advertising ID, approximate usage/diagnostics)
- ⬜ (Optional) Add the runtime ATT prompt via the `app_tracking_transparency`
  package if you want personalized ads on iOS; otherwise serve non-personalized
  ads to skip the prompt.

## 4. Android release
- ✅ Signing scaffold: `android/app/build.gradle.kts` reads `key.properties`
  when present and falls back to debug keys otherwise
- ✅ `key.properties.example` template committed; real `key.properties`,
  `*.jks`, `*.keystore` are gitignored
- ⬜ Generate an upload keystore and create `android/key.properties`
- ⬜ Enroll in **Play App Signing**
- ⬜ Build the bundle (needs Android SDK + JDK 17):
  ```bash
  flutter build appbundle --release
  ```
- ⬜ Upload the `.aab` to Play Console → Internal testing → Production

## 5. iOS release
- ⬜ Create App ID + provisioning profiles (Apple Developer portal)
- ⬜ Create the app record in App Store Connect
- ⬜ Build & archive (needs macOS + Xcode):
  ```bash
  flutter build ipa --release
  ```
- ⬜ Upload via Transporter / Xcode → TestFlight → App Review

## 6. Store listing assets
- ✅ Draft copy in `store_listing.md` (title, subtitle, descriptions, keywords)
- ⬜ Screenshots for required device sizes (phone; iPad/tablet optional)
- ⬜ Feature graphic 1024×500 (Play), promo text
- ⬜ Content rating questionnaire + target audience

## 7. Pre-submit verification
- ✅ `flutter analyze` — no issues
- ✅ `flutter test` — passing
- ⬜ `flutter build appbundle --release` / `flutter build ipa --release` succeed
  on a machine with the toolchains (not available in the current cloud env)
- ⬜ Smoke test on a physical Android + iOS device

## Regenerating icon & splash
If you tweak `assets/icon/aura_icon.png` (square 1024×1024) or
`assets/icon/aura_icon_fg.png` (transparent, padded):
```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```
