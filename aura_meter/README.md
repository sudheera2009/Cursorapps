# 🔮 AURA METER

**Scan your aura. Farm your vibe. Beat your friends.**

AURA METER is a viral, shareable novelty app built with Flutter. Place your
finger on the biometric-style scanner and let the app "read your energy" — you
get an aura score (0–9999), an aura type, and a slick shareable card. It leans
hard into the trending *"aura points / aura farming"* internet culture to drive
downloads and organic sharing.

> ⚠️ For entertainment only. Aura readings are randomly generated and are not a
> real measurement of anything. It's a party/meme app.

## ✨ Why it attracts downloads

- **Hyper-shareable results** — every scan produces a branded aura card built
  for screenshots and stories (`#AuraMeter`).
- **Rarity & collection loop** — 10 aura types from *common* to *mythic*
  (Prismatic Chaos 🌈). Gotta scan 'em all.
- **Aura duels** — challenge friends; higher aura wins. Instant social hook.
- **Daily engagement** — Aura of the Day, daily streaks, and rotating daily
  challenges bring players back.
- **Progression & flex** — levels, aura points currency, unlockable card frames,
  achievements, and a simulated global leaderboard.

## 🎮 Features

| Area | Details |
| --- | --- |
| Scan | Hold-to-scan fingerprint animation with rising haptics & status readout |
| Results | Animated orb, trait breakdown (Charisma / Chaos / Luck / Mystery), confetti on rare pulls, share + rewarded "2× aura" |
| Collection | Aura-type dex + full scan history |
| Duels | Simulated aura battles, win rate tracking, rematch |
| Ranks | Simulated global leaderboard the player slots into by best score |
| Shop | Unlockable card frames + rewarded ad for free aura |
| Awards | 14 achievements across scans, scores, rarity, streaks & duels |
| Profile | Stats dashboard + one-tap stats sharing |
| Settings | Haptics / sound / animations toggles, reset progress |

## 🧱 Architecture

```
lib/
├── core/            # theme & shared visual language
├── models/          # aura types, readings, profile, frames, achievements, challenges
├── providers/       # AuraProvider (ChangeNotifier) — scan logic & persistence
├── services/        # ads, haptic/feedback, share
├── screens/         # splash, onboarding, home, scan, result, collection, duel,
│                    #   ranks, shop, awards, profile, settings
└── widgets/         # animated background, aura orb, glass cards, share card, banner ad
```

- **State**: `provider` + a single `AuraProvider`.
- **Persistence**: `shared_preferences` (profile, history, streaks, dailies).
- **Ads**: `google_mobile_ads` wired with Google's public **test** ad units.
  Swap in real ad unit IDs and the AdMob app IDs (Android manifest / iOS plist)
  before shipping.

## 🚀 Getting started

```bash
cd aura_meter
flutter pub get
flutter run
```

Requires Flutter 3.8+.
