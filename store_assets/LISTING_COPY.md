# ChromaPulse — Ready-to-paste store listing copy

SEO-tuned for App Store and Google Play. Every field ≤ its platform limit.
Every word counts — title/subtitle/keywords are the three biggest ranking signals on Apple.

---

## Apple App Store Connect

### App Name (30 char limit — primary SEO field)
```
ChromaPulse: Color Eye Test
```
**27 chars.** Packs the #1 search term ("color") plus two high-volume secondaries ("eye test").

### Subtitle (30 char limit — second-highest SEO weight)
```
Train Your Hue & Shade Vision
```
**29 chars.** Adds "hue", "shade", "vision" — all discoverable terms that don't duplicate the title.

### Keywords (100 char limit — comma-separated, no spaces, singular)
```
rgb,chroma,perception,puzzle,brain,match,designer,artist,photographer,pixel,palette,paint,memory
```
**99 chars.** Apple auto-indexes app name + subtitle, so these keywords *avoid* repeating
"color / eye / test / hue / shade / vision / train" and instead cover every other high-intent
search term (RGB mixers, color-match players, designer/artist/photographer niches).

### Promotional Text (170 char limit — editable any time without re-review)
```
4 color-vision games in one. Spot the odd shade, mix RGB, recall a flashed hue, find the outlier. Free to play. No account. Perfect for designers, artists, photographers.
```
**170 chars exactly.**

### Description (4000 char limit)
```
ChromaPulse is the fastest way to train your color vision. Four bite-sized modes push your eye for hue, shade, and RGB mixing — all in a clean, dark, minimal design built for 2-minute sessions.

FOUR MODES. ONE COLOR EYE TEST.

◐ SHADE HUNTER — Find the darkest or lightest tile in a grid of nearly-identical shades. Each round, the difference shrinks. How tight can you see?

◈ ODD CHROMA — One tile has a slightly different hue. Spot the impostor before the timer runs out. Perfect for testing color blindness and sharpening hue sensitivity.

◉ CHROMA RECALL — A target color flashes for a split second. Remember it. Now find it among near-identical shades. The ultimate color memory test.

◎ COLOR ALCHEMIST — Mix red, green, and blue sliders to recreate a target color. The closer your match, the more points you earn. A pure RGB picker workout.

WHY CHROMAPULSE?

• Adaptive difficulty — every round tighter than the last
• Combo multiplier for back-to-back correct answers
• Speed bonuses for lightning decisions
• Persistent best scores, separately tracked per mode
• Stats dashboard: games played, total points, accuracy %
• Clean, distraction-free design built for short sessions
• Free to play — no forced signup, no energy system, no paywalls blocking content

PERFECT FOR:

• Graphic designers sharpening their eye for hue and saturation
• Digital artists and illustrators training color accuracy
• Photographers calibrating their perception of shade and tone
• Front-end developers working with hex and RGB values
• UI/UX designers choosing palettes
• Anyone curious about their color vision or color blindness
• Brain-training fans looking for a fresh daily challenge

ChromaPulse is a color-perception trainer disguised as a fast, beautifully minimal game. Two minutes a day and you will see the difference — literally.

Free to play. Optional one-time purchase removes ads or unlocks the VIP Pass for ad-free play and future bonus content. No subscriptions, ever.
```

### What's New in This Version (4000 chars — for 1.0.0 use the simple one)
```
Initial release.

• Four color-vision modes: Shade Hunter, Odd Chroma, Chroma Recall, Color Alchemist
• Adaptive difficulty that scales to your eye
• Combo and speed scoring
• Per-mode best scores, stats dashboard, and streak tracking
```

### Support URL
```
https://github.com/nalhamzy/chromapulse
```

### Marketing URL (optional — leave blank or use support URL)
```

```

### Privacy Policy URL
```
https://nalhamzy.github.io/chromapulse/privacy.html
```
*(Host the privacy template from STORE_SETUP_GUIDE.md §7 first.)*

### Copyright
```
2026 Ideal AI
```

### Category
- Primary: **Games → Puzzle**
- Secondary: **Games → Casual**

### Age Rating
- **4+** (Made for Kids: **NO**)

### App Review — Review Notes
```
ChromaPulse has no account, login, or server backend. All stats are stored locally via SharedPreferences. IAPs are two non-consumables (chromapulse_remove_ads, chromapulse_vip_pass). Sandbox purchases can be verified with any tester account. Ads use AdMob. No demo account required.
```

### App Review — Contact Info
- First name / Last name / Phone / Email — your real info
- Demo Account username/password — **leave blank** (no login in app)

---

## Apple In-App Purchases

### Product 1 — Remove Ads

| Field | Value |
|---|---|
| Product ID | `chromapulse_remove_ads` |
| Reference Name | `Remove Ads` |
| Type | Non-Consumable |
| Price Tier | Tier 2 ($1.99) |
| Display Name | `Remove Ads` |
| Description | `Hide banner and interstitial ads forever. One-time purchase, yours for life. Support ChromaPulse and play distraction-free.` |
| Review Notes | `Non-consumable upgrade. To reproduce: launch app → tap SHOP → tap the Remove Ads tile. Validate in sandbox with any tester account.` |

### Product 2 — VIP Pass

| Field | Value |
|---|---|
| Product ID | `chromapulse_vip_pass` |
| Reference Name | `VIP Pass` |
| Type | Non-Consumable |
| Price Tier | Tier 5 ($4.99) |
| Display Name | `VIP Pass` |
| Description | `Remove all ads forever and unlock future bonus content, including new color modes and exclusive themes. The ultimate ChromaPulse experience.` |
| Review Notes | `Non-consumable upgrade. To reproduce: launch app → tap SHOP → tap the VIP Pass tile. Validate in sandbox with any tester account.` |

---

## Google Play Console

### App Name (30 char limit)
```
ChromaPulse: Color Eye Test
```

### Short Description (80 char limit)
```
Train your color vision. 4 addictive games for hue, shade, RGB and memory.
```
**74 chars.** Hits every primary keyword in one line.

### Full Description (4000 char limit)
*Use the same description block as Apple above.*

### Tags (pick up to 5)
```
Color, Puzzle, Brain training, Casual, Minimal
```

### App Category
**Games → Puzzle**

### Content Rating
**Everyone** (PEGI 3 / USK 0 / ESRB Everyone)

### Contact Email
```
nalhamzy@gmail.com
```

### Website (optional)
```
https://github.com/nalhamzy/chromapulse
```

### Privacy Policy
```
https://nalhamzy.github.io/chromapulse/privacy.html
```

### Target Audience
**Ages 13–17 and 18+** (NOT "Designed for Families")

---

## Google Play In-App Products

### Product 1

| Field | Value |
|---|---|
| Product ID | `chromapulse_remove_ads` |
| Name | `Remove Ads` |
| Description | `Hide banner and interstitial ads forever. One-time purchase. Support ChromaPulse development.` |
| Price | `$1.99 USD` |
| State | Active |

### Product 2

| Field | Value |
|---|---|
| Product ID | `chromapulse_vip_pass` |
| Name | `VIP Pass` |
| Description | `Remove ads forever and unlock future bonus content, new modes, and exclusive themes. The ultimate ChromaPulse experience.` |
| Price | `$4.99 USD` |
| State | Active |

---

## Screenshot captions (iPhone / iPad / Android — optional but recommended)

If your framing includes text overlays, use these. Keep under ~40 chars per line.

| # | Caption |
|---|---|
| 01_menu | `Four ways to test your color vision.` |
| 02_shade_hunter | `Spot the odd shade before the timer.` |
| 03_color_alchemist | `Mix R, G, B — match the target exactly.` |
| 04_chroma_recall | `Flash. Remember. Find the hue.` |
| 05_stats | `Streaks, bests, accuracy — all tracked.` |
| 06_shop | `No ads forever. One-time purchase.` |

---

## Content-rating questionnaire — answers (both stores)

Use these identically on App Store Connect and Google Play IARC:

| Question | Answer |
|---|---|
| Violence (any kind) | None |
| Gore / blood | None |
| Sexual content / nudity | None |
| Profanity / crude humor | None |
| Horror / fear themes | None |
| Suggestive / mature themes | None |
| Simulated gambling | None |
| Alcohol / tobacco / drugs | None |
| Medical / treatment info | None |
| Unrestricted web access | No |
| User-generated content | No |
| Real-money gambling | No |
| Loot boxes / randomized purchases | No |
| Purchase of physical goods | No |
| Shares user location | No |
| Digital purchases (IAPs) | Yes — `chromapulse_remove_ads`, `chromapulse_vip_pass` |
| Targeted at children under 13 | **No** |

Expected rating: **4+ / Everyone / PEGI 3**.
