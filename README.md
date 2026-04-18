# ChromaPulse

A color perception trainer for iOS and Android, built with Flutter.

Four distinct modes challenge different visual skills:

| Mode | Skill | Icon |
|---|---|---|
| **Shade Hunter** | Spot the darkest / lightest tile among similar shades | ◐ |
| **Odd Chroma** | Find the one tile with a slightly different hue | ◈ |
| **Chroma Recall** | Memorize a flashed color, then pick it from similar shades | ◉ |
| **Color Alchemist** | Mix R/G/B sliders to recreate a target color | ◎ |

Each game is 10 rounds (8 for Alchemist) with adaptive difficulty, a combo multiplier, and persistent best scores per mode.

## Quick start

```bash
flutter pub get
flutter run
```

Requires Flutter stable (Dart SDK ≥ 3.11.0).

## Run tests

```bash
flutter test
```

## Project structure

```
lib/
├── main.dart                  Boot: SharedPreferences + portrait lock + ProviderScope
├── app.dart                   MaterialApp + _AppShell (screen routing + ad banner + IAP callbacks)
├── core/
│   ├── constants/             Palette + theme + AdMob unit IDs
│   ├── models/                Game state, game mode, round config, feedback kinds, player stats
│   ├── services/              Storage, audio, ad service (mobile + web split), IAP service (mobile + web split)
│   └── utils/                 Responsive helpers + color math (HSL→RGB, distance, accuracy)
├── providers/                 Riverpod providers (game, player, screen, audio, ad, iap)
├── screens/                   Menu / Game / Result / Shop
└── widgets/
    ├── common/                Buttons, logo, section card, ad banner
    └── game/                  Color grid/cell, timer bar, blend area, sliders, memory flash, toasts
```

## Architecture notes

- **State management:** [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) Notifier providers. No routes — a single `AppScreen` enum + `AnimatedSwitcher` in `_AppShell`.
- **Responsive by default:** every UI size flows through `context.s(v)` which scales up ~1.55× on tablets (shortestSide ≥ 600dp). Layouts wrap with `ResponsiveContentBox` to avoid ugly full-width stretching on iPads.
- **Web-safe services:** `ad_service.dart` and `iap_service.dart` use conditional exports so the app compiles for both mobile (with `google_mobile_ads` + `in_app_purchase`) and web (no-op stubs). This is deliberate — retrofitting web-safety is painful; paying the 20-LOC cost upfront is cheap.
- **Purchase API:** `iap.purchase(String productId) → Future<bool>` returns the launch status without leaking `ProductDetails` into the UI layer. Callbacks fire with the plain product ID string.

## Deployment

See [RELEASE.md](RELEASE.md) for the full App Store Connect + Google Play Console + Codemagic walkthrough.

**Quick summary:**
1. Bump version in `pubspec.yaml`
2. `git tag v1.0.x && git push --tags`
3. Codemagic builds both platforms, uploads iOS to TestFlight, uploads Android AAB to Play Production (as draft)

## AdMob & IAP

- **Default AdMob unit IDs are Google's public test IDs** — safe for development, **must** be replaced before production release. See [lib/core/constants/ad_ids.dart](lib/core/constants/ad_ids.dart).
- **IAP products (both non-consumable):**
  - `chromapulse_remove_ads` → hides banner + interstitial
  - `chromapulse_vip_pass` → removes ads + future bonus content flag
- No consumable coin economy. No ads during gameplay (banner hides on `AppScreen.game`).

## License

Proprietary — all rights reserved.
