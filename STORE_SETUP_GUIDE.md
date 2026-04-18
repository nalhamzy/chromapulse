# ChromaPulse — Store Setup Guide for a Browser Assistant

**Purpose of this document:** paste this entire file into any browser-based coding/AI assistant (ChatGPT, Claude web, Gemini, etc.) as context, then ask the assistant to walk you step-by-step through creating the store listings, AdMob account, IAP products, and all metadata. The assistant will use this as the source of truth for app identity, copy, and answers to review questionnaires.

**How to use with an assistant:**
1. Start a fresh browser chat with your preferred AI assistant.
2. Paste this whole document.
3. Say: *"Walk me through step 1 first. After each step, stop and wait for me to confirm before moving to the next."*
4. Follow along in each web console, pasting values from the tables below.

---

## 0. App identity (never change these — code already references them)

| Field | Value |
|---|---|
| **App name** | ChromaPulse |
| **Tagline / subtitle** | Train Your Color Vision |
| **Bundle ID (iOS)** | `com.idealai.chromapulse` |
| **Application ID (Android)** | `com.idealai.chromapulse` |
| **Primary category** | Games → Puzzle |
| **Secondary category** | Games → Casual |
| **Age rating target** | 4+ / Everyone (NOT Kids Category) |
| **Pricing** | Free, with in-app purchases + ads |
| **Default locale** | English (United States) |
| **Supported devices** | iPhone, iPad, Android phones & tablets |
| **Supported orientations** | iPhone: Portrait only. iPad & Android: all orientations. |
| **Monetization** | Banner + interstitial ads (AdMob), 2 non-consumable IAPs |
| **Developer name** | Ideal AI |
| **Support email** | nalhamzy@gmail.com |
| **Support URL** | *(you need to create one — GitHub repo link or a static page is fine)* |
| **Marketing URL** | *(optional; leave blank initially)* |
| **Privacy Policy URL** | *(see §7 — you must host one before submitting)* |
| **Copyright line** | `2026 Ideal AI` |

---

## 1. AdMob account setup

**Goal:** get two AdMob app IDs (iOS + Android) and six ad unit IDs (banner/interstitial/rewarded × 2 platforms). These replace the test IDs currently in the code.

**URL:** https://admob.google.com

### Step 1.1 — Create AdMob account (if new)
- Sign in with the same Google account you'll use for Google Play Console (recommended — simplifies linking).
- Accept T&Cs. Fill in country/time-zone/billing currency.
- AdMob doesn't charge anything; it's how Google pays you.

### Step 1.2 — Create the iOS app in AdMob
- **Apps** → **Add app** → **Apple**
- "Is the app listed on the App Store?" → **No** (first time; you'll link after the App Store Connect record exists in §2)
- App name: `ChromaPulse`
- Platform: iOS
- User metrics: enable (optional)
- Copy the **App ID** (format: `ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY`). Save it to `lib/core/constants/ad_ids.dart` `_prodBannerIos`-style constants and to `ios/Runner/Info.plist` under `GADApplicationIdentifier`.

### Step 1.3 — Create the Android app in AdMob
- Repeat Step 1.2 with platform **Android**, name `ChromaPulse`.
- Save the App ID into `android/app/src/main/AndroidManifest.xml` under `com.google.android.gms.ads.APPLICATION_ID`.

### Step 1.4 — Create 6 ad units (3 per platform)
For each AdMob app, create three ad units:

| Unit name | Format | Notes |
|---|---|---|
| ChromaPulse Banner | Banner | Standard 320×50 |
| ChromaPulse Interstitial | Interstitial | Full-screen |
| ChromaPulse Rewarded | Rewarded | Optional; reserved for future "+score" flows |

Copy each unit ID into `lib/core/constants/ad_ids.dart` (`_prodBannerIos`, `_prodBannerAndroid`, etc.). Replace the test IDs in the `_prod*` constants.

### Step 1.5 — Privacy & compliance
- In AdMob → **Privacy & messaging** → **GDPR** & **IDFA**: create the user messaging platform (UMP) consent forms. Enable both.
- In **App settings** for each app → **User metrics** → leave enabled.
- **Blocking controls** → block categories your audience shouldn't see (Gambling, Dating) as a minimum.

---

## 2. Apple App Store Connect — complete setup

**URL:** https://appstoreconnect.apple.com
**Prereq:** paid Apple Developer account ($99/yr) at https://developer.apple.com/programs

### Step 2.1 — Register Bundle ID in Apple Developer portal
https://developer.apple.com/account/resources/identifiers/list → **+**
- App IDs → App
- Description: `ChromaPulse iOS`
- Bundle ID: Explicit → `com.idealai.chromapulse`
- Capabilities: check **In-App Purchase**
- Register

### Step 2.2 — Create the App Store Connect record
App Store Connect → **My Apps** → **+** → **New App**
- Platforms: iOS
- Name: `ChromaPulse` (if taken, try `ChromaPulse: Color Vision` or `ChromaPulse Game`)
- Primary Language: English (U.S.)
- Bundle ID: `com.idealai.chromapulse`
- SKU: `chromapulse-ios-001`
- User Access: Full Access
- Create

### Step 2.3 — App Information
- Category: Primary **Games → Puzzle**; Secondary **Games → Casual**
- Content Rights: "No, it does not contain, show, or access third-party content"
- **Made for Kids: NO** (critical — do not enable the Kids Age Band toggle)
- Age Rating: open the questionnaire; answers are in §6 below

### Step 2.4 — Pricing and Availability
- Price: Free (Tier 0)
- Availability: All countries/regions (or select specific ones)

### Step 2.5 — Privacy
**App Privacy** → **Get Started** → declare the following data collection (from AdMob SDK):

| Data type | Collected? | Linked to user? | Used for tracking? | Purpose |
|---|---|---|---|---|
| Device ID (IDFA) | Yes | No | Yes | Third-Party Advertising |
| Purchase History | Yes | Yes | No | App Functionality |
| Product Interaction | Yes | No | No | Analytics |
| Crash Data | Yes | No | No | App Functionality |
| Performance Data | Yes | No | No | App Functionality |

Answer "**No**" to: Contact Info, Health, Financial Info, Location, Sensitive Info, Contacts, User Content, Search History, Identifiers (other than IDFA), Usage Data beyond above, Diagnostics beyond above.

### Step 2.6 — In-App Purchases
**Features** → **In-App Purchases** → **+**

Create both as **Non-Consumable**:

| Product ID | Reference Name | Price Tier | Display Name | Description |
|---|---|---|---|---|
| `chromapulse_remove_ads` | Remove Ads | Tier 2 ($1.99) | Remove Ads | Hide banner and interstitial ads forever. Keep supporting ChromaPulse! |
| `chromapulse_vip_pass` | VIP Pass | Tier 5 ($4.99) | VIP Pass | Removes all ads and unlocks future bonus content. The ultimate ChromaPulse experience. |

For each IAP:
- **Localization**: at least English (U.S.) with Display Name + Description above
- **Review Screenshot**: capture `GameScreen → Shop` at 1290×2796 showing the product tile. See §5.3 for capture instructions.
- **Review Notes** (paste verbatim):
  > This is a non-consumable upgrade purchased from the ChromaPulse in-app shop. To reproduce: launch app → tap SHOP in the menu → tap the price button on this product. Purchase can be validated in sandbox with any tester account. No external accounts required.

**⚠ Product IDs must match the code exactly.** Do not rename them.

### Step 2.7 — Version information (first version)
On the `1.0.0` version page, fill in:

**Promotional Text** (170 chars max, editable without re-submission):
> Train your color vision with four unique challenges: spot the odd shade, recall colors from memory, mix RGB to match, and find the outlier.

**Description** (4000 chars):
> ChromaPulse is a color-perception trainer disguised as a fast, beautifully minimal game. Four distinct modes push your visual skills to the limit:
>
> ◐ **SHADE HUNTER** — Find the darkest or lightest tile in a grid of nearly identical shades. As you progress, the difference shrinks.
>
> ◈ **ODD CHROMA** — One tile has a slightly different hue. Spot the impostor as the hue gap narrows round by round.
>
> ◉ **CHROMA RECALL** — A target color flashes for a split second. Remember it. Now find it among near-identical shades.
>
> ◎ **COLOR ALCHEMIST** — Mix R, G, and B sliders to recreate a target color exactly. The closer you get, the more points you earn.
>
> **Features:**
> • Adaptive difficulty — every round harder than the last
> • Combo multiplier for back-to-back correct answers
> • Speed bonuses for lightning-fast decisions
> • Persistent best score tracked separately for each mode
> • Stats dashboard: games played, total points, accuracy %
> • Clean, distraction-free design built for short sessions
>
> Perfect for designers, artists, photographers, or anyone who wants to sharpen their color eye. Two minutes a day, and you'll see the difference.
>
> ChromaPulse is free to play. Optional in-app purchases remove ads or unlock the VIP Pass.

**Keywords** (100 chars, comma-separated, no spaces between):
> color,eye,vision,test,perception,hue,rgb,memory,training,brain,puzzle,chromatic,art,designer,match

**Support URL:** `https://github.com/nalhamzy/chromapulse` *(or any public URL)*
**Marketing URL:** *(blank or same)*

**Version release:** "Automatically release this version" (or "Manually release" for safety)

**What's New in This Version** (for updates only — leave blank for 1.0.0):
> Initial release. Four color-vision modes. Adaptive difficulty. Combo scoring.

**Copyright:** `2026 Ideal AI`
**Routing App Coverage File:** N/A

**Contact Information:**
- First name / Last name / Phone / Email — yours
- **Demo Account** — leave blank (app has no login)

**App Review Information — Notes** (paste):
> ChromaPulse has no account, login, or server backend. All stats are stored locally via SharedPreferences. IAPs are two non-consumables (chromapulse_remove_ads, chromapulse_vip_pass). Sandbox purchases can be verified with any tester account. Ads use AdMob.

### Step 2.8 — App Store Connect API Key for Codemagic
**Users and Access** → **Keys** → **+** → App Store Connect API
- Name: `Codemagic Upload`
- Access: **App Manager**
- Download the `.p8` file (one-time download!), note **Issuer ID** and **Key ID**
- Paste these three into Codemagic → Team Integrations → Apple Developer Portal, name the integration `admin`

### Step 2.9 — Paid Apps Agreement
**Agreements, Tax, and Banking** → **Paid Apps** must be **Active**. This requires:
- Tax forms (W-9 or W-8BEN)
- Banking info (SWIFT/IBAN)
- Apple legal terms acceptance

⚠ If Paid Apps status is anything other than Active, IAPs return empty in production (sandbox still works — this is why many devs miss it).

---

## 3. Google Play Console — complete setup

**URL:** https://play.google.com/console
**Prereq:** paid Google Play Developer account ($25 one-time)

### Step 3.1 — Create the app
**All apps** → **Create app**
- App name: `ChromaPulse`
- Default language: English (United States) – en-US
- App or game: Game
- Free or paid: Free
- Declarations: tick both (guidelines + US export laws)
- **Create app**

### Step 3.2 — Store listing
**Grow** → **Store presence** → **Main store listing**

- **App name:** ChromaPulse
- **Short description** (80 chars):
  > Four addictive color-vision challenges. Train your eye for hue, shade, and recall.
- **Full description** (4000 chars): paste the same description as §2.7
- **App icon:** 512×512 PNG (from `flutter_launcher_icons` output — see §5.2)
- **Feature graphic:** 1024×500 PNG
- **Screenshots:** see §5
- **App category:** Games → Puzzle
- **Tags:** Color, Puzzle, Casual, Brain training (pick up to 5)
- **Contact details:**
  - Email: `nalhamzy@gmail.com`
  - Website: optional
  - Privacy policy: **required URL** (see §7)

### Step 3.3 — App content declarations
**Policy** → **App content** — you must complete ALL of these before submitting:

| Item | Answer |
|---|---|
| Privacy policy | Paste URL from §7 |
| App access | All functionality available without restrictions |
| Ads | **Yes, my app contains ads** |
| Content rating questionnaire | See §6 |
| Target audience | Ages 13–17 and 18+ (NOT "Designed for Families") |
| News app | No |
| COVID-19 contact tracing | No |
| Data safety | See §3.4 below |
| Government app | No |
| Financial features | No |
| Health | No |
| Social | No |
| Gambling / loot boxes | No |

### Step 3.4 — Data safety form
**Policy** → **App content** → **Data safety**

Data collected and shared (from AdMob SDK):

| Data type | Collected | Shared | Purpose | Optional? |
|---|---|---|---|---|
| Advertising ID / device ID | Yes | Yes | Advertising / marketing, Analytics | No |
| App interactions | Yes | No | Analytics | No |
| Crash logs | Yes | No | App functionality | No |
| Diagnostics | Yes | No | App functionality | No |
| Purchase history | Yes | No | App functionality | No |

Security practices:
- Data is encrypted in transit: **Yes** (AdMob uses HTTPS)
- You provide a way to request data deletion: **Yes** (user can delete app to clear all local data; for advertising ID reset, provide instructions: "Reset advertising ID via device Settings → Google → Ads")
- Committed to Play Families Policy: **No** (we're not in Families program)
- Independently validated: **No**

### Step 3.5 — In-app products
**Monetize** → **Products** → **In-app products** → **Create product**

For EACH product:

| Product ID (exact match!) | Name | Description | Default price |
|---|---|---|---|
| `chromapulse_remove_ads` | Remove Ads | Hide banner and interstitial ads forever. Support ChromaPulse development! | $1.99 USD |
| `chromapulse_vip_pass` | VIP Pass | Removes all ads and unlocks future bonus content. The ultimate ChromaPulse experience. | $4.99 USD |

Both must be **Active** state.

### Step 3.6 — Upload first AAB to Internal testing
**Testing** → **Internal testing** → **Create new release**
- Drag in `build/app/outputs/bundle/release/app-release.aab`
- Enroll in **Play App Signing** (one-time, irrevocable — Google holds the real signing key, you keep the upload key)
- Release name: `1.0.0 (1)`
- Release notes:
  > Initial release. Four color-vision training modes with adaptive difficulty.
- **Save** → **Review release** → **Start rollout to Internal testing**
- Add yourself as a tester under **Testers** tab

### Step 3.7 — Google Cloud service account for Codemagic
https://console.cloud.google.com → new project → **IAM & Admin** → **Service Accounts** → **+ CREATE SERVICE ACCOUNT**
- Name: `codemagic-publisher`
- Skip role grants
- Open the new account → **Keys** → **Add key** → **Create new key** → JSON → download

Then in Play Console:
- **Users and permissions** → **Invite new users** → email = service account email (`codemagic-publisher@YOUR-PROJECT.iam.gserviceaccount.com`)
- App permissions: Release manager for ChromaPulse
- Send invitation — the service account auto-accepts

Paste the JSON contents into Codemagic → Environment Variables → group `google_play` → variable `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS` (marked Secure).

### Step 3.8 — Content rating
**Policy** → **App content** → **Content ratings** → **Start questionnaire**
- Category: Game
- Email: your email
- See §6 for answers

Submit the questionnaire. Google issues IARC ratings automatically. ChromaPulse should receive **Everyone** / **PEGI 3** / **USK 0**.

---

## 4. Store listing copy — short, medium, long variants

For the assistant to reuse or paraphrase:

### Tagline (30 chars)
> Train Your Color Vision

### One-liner (80 chars — Google Play short description)
> Four addictive color-vision challenges. Train your eye for hue, shade, and recall.

### Two-liner (for social, promo text)
> ChromaPulse is a fast, minimal color-perception trainer. Four modes — Shade Hunter, Odd Chroma, Chroma Recall, Color Alchemist — push your visual skills to the limit.

### 50-word paragraph (App Store subtitle / press kit)
> ChromaPulse trains your color vision through four distinct challenges: find the darkest shade, spot the odd hue, recall a flashed color, or mix RGB to match. Adaptive difficulty, combo multipliers, and per-mode high scores make every session sharper than the last. Free with optional in-app purchases.

### Full description (use §2.7)

### Keywords (App Store, 100 chars, no spaces inside commas)
> color,eye,vision,test,perception,hue,rgb,memory,training,brain,puzzle,chromatic,art,designer,match

### Google Play tags (up to 5)
> Color, Puzzle, Casual, Brain training, Minimal

---

## 5. Visual assets checklist

### 5.1 — App icon (1024×1024)
**Required everywhere.** One master PNG at `assets/icon/icon_source.png`, then:
```bash
dart run flutter_launcher_icons
```
This generates all iOS AppIcon sizes and Android mipmap densities.

**Design prompt for AI image generators:**
> A minimal, modern app icon for ChromaPulse — a color-vision training game. Gradient "C" letter shape on a near-black background (#0A0A0F). Use a mint-green to purple gradient (#00FFAA → #7B61FF). Clean geometric shape, flat design, no text, sharp edges, 1024×1024 PNG, vector-style.

### 5.2 — Feature graphic (Google Play, 1024×500)
**Design prompt:**
> A horizontal banner for the ChromaPulse app. Dark background (#0A0A0F) with four color swatches in a row (mint #00FFAA, purple #7B61FF, coral #FF3366, gold #FFD700). Title "CHROMAPULSE" in bold sans-serif (Outfit font or similar) on the left, tagline "Train Your Color Vision" below. Modern, minimal, 1024×500 PNG.

### 5.3 — Screenshots

Capture from **iOS Simulator → iPhone 15 Pro Max** (gives 1290×2796 natively) and **iPad Pro 13-inch** (2064×2752). For Android, an emulator or real phone is fine.

Required screenshots (all platforms):
1. **Menu screen** — showing the 4 mode cards with stats bar
2. **Shade Hunter gameplay** — mid-round, grid visible with active timer
3. **Chroma Recall memory flash** — the full-screen "REMEMBER THIS COLOR" moment
4. **Color Alchemist** — sliders mid-mix with target/preview swatches
5. **Result screen** — showing score, "NEW BEST" badge, stats

**Minimums:**
- **iPhone 6.9" (1290×2796):** 3 required, 5 recommended — **required** for App Store
- **iPad 13" (2064×2752):** 3 required — **required if iPad supported** (ChromaPulse is, so: required)
- **Android phone:** 2 required, 8 recommended (1080×1920 or similar)
- **Android 7" tablet** and **10" tablet:** 1 required each (skippable on first submission)

**⚠ Apple rejection trap (learned from color_chaos):** iPad screenshots must show the iPad layout — ChromaPulse's `ResponsiveContentBox` + `context.s()` scaling handles this. Do NOT submit phone screenshots padded to iPad canvas. Capture on an actual iPad simulator.

### 5.4 — App preview video (optional but recommended)
15–30 seconds showing all four modes. Capture with iOS Simulator screen-record. App Store accepts `.mov` at the same resolutions as screenshots.

---

## 6. Age rating & content questionnaire answers

Use these answers consistently across App Store Connect and Google Play:

| Question | Answer |
|---|---|
| Violence (cartoon / fantasy / realistic) | None |
| Gore / blood | None |
| Sexual content / nudity | None |
| Profanity / crude humor | None |
| Horror / fear themes | None |
| Mature / suggestive themes | None |
| Simulated gambling | None |
| Alcohol / tobacco / drug references | None |
| Medical / treatment information | None |
| Unrestricted web access | No |
| User-generated content | No |
| Gambling / contests with real money | No |
| Loot boxes / randomized purchases | No |
| Purchase of physical goods | No |
| Shares user location | No |
| Digital purchases (IAPs) | Yes — chromapulse_remove_ads, chromapulse_vip_pass |
| Targeted at children under 13 | **No** |

**Expected rating outcomes:**
- Apple: **4+**
- Google Play: **Everyone**
- PEGI: **3**
- USK: **0**
- ESRB: **Everyone**

---

## 7. Privacy policy

You **must** host a privacy policy at a public URL before submitting to either store. Options:
- Free: GitHub Pages, Netlify, a Notion public page
- Template generators: https://www.termsfeed.com/privacy-policy-generator, https://app-privacy-policy-generator.nisrulz.com

### Privacy policy template (paste into a generator or static page)

```markdown
# Privacy Policy for ChromaPulse

Last updated: 2026-04-15

Ideal AI ("we", "us") operates the ChromaPulse mobile application (the "App").
This policy explains what information the App collects and how it's used.

## Data we collect
- **Gameplay statistics** (games played, scores, accuracy) — stored locally on your device only. Never sent to our servers.
- **Advertising identifier** — used by Google AdMob to serve ads.
- **Crash and performance diagnostics** — used by Google AdMob and your device's operating system to improve stability.
- **Purchase history** — used by Apple App Store / Google Play to validate in-app purchases.

We do NOT collect: your name, email, contacts, location, photos, health data,
financial data, or any other personally identifying information.

## How data is used
- All gameplay data stays on your device.
- AdMob uses your advertising identifier to show relevant ads. You can reset
  this identifier at any time via your device Settings.
- Purchase history is used by the platform store only to validate entitlements.

## Third-party services
- **Google AdMob** — advertising. Privacy policy: https://policies.google.com/privacy
- **Apple App Store / Google Play** — platform services and in-app purchases.

## Your rights
- You can delete all locally stored data by uninstalling the App.
- You can reset your advertising identifier:
  - iOS: Settings → Privacy & Security → Tracking
  - Android: Settings → Google → Ads
- You can opt out of personalized ads at https://adssettings.google.com

## Children's privacy
ChromaPulse is not directed at children under 13. We do not knowingly collect
data from children under 13. If you believe a child has used the App, please
contact us below and we'll delete any associated data.

## Contact
Questions? Email nalhamzy@gmail.com.

## Changes to this policy
We may update this policy over time. The "Last updated" date at the top
reflects the most recent revision.
```

Host this at e.g. `https://nalhamzy.github.io/chromapulse/privacy.html` and use that URL in both store listings.

---

## 8. Pre-submission checklist

### Code-side (local, before first tag)
- [ ] Replace AdMob test IDs with real ones in:
  - `lib/core/constants/ad_ids.dart` (`_prod*` constants)
  - `android/app/src/main/AndroidManifest.xml` (`com.google.android.gms.ads.APPLICATION_ID`)
  - `ios/Runner/Info.plist` (`GADApplicationIdentifier`)
- [ ] Generate app icon: drop `assets/icon/icon_source.png` → run `dart run flutter_launcher_icons`
- [ ] Generate Android upload keystore (see RELEASE.md §2)
- [ ] Fill in `android/key.properties` from template
- [ ] Run `flutter analyze` — 0 issues
- [ ] Run `flutter test` — all pass
- [ ] Run `flutter build appbundle --release` — succeeds locally

### App Store Connect
- [ ] App record created with correct bundle ID
- [ ] Category set (Games → Puzzle, NOT Kids)
- [ ] Pricing = Free
- [ ] App Privacy questionnaire complete
- [ ] Description + Keywords + Promotional Text filled
- [ ] App Icon uploaded (1024×1024)
- [ ] 3+ iPhone 6.9" screenshots uploaded
- [ ] 3+ iPad 13" screenshots uploaded (showing iPad layout, not phone-column)
- [ ] Both IAPs (`chromapulse_remove_ads`, `chromapulse_vip_pass`) configured and in "Ready to Submit"
- [ ] IAP review screenshots uploaded
- [ ] IAPs attached to the version under review
- [ ] Paid Apps Agreement = Active
- [ ] App Store Connect API Key generated and added to Codemagic as `admin`
- [ ] Privacy Policy URL live and reachable
- [ ] Support URL live
- [ ] Age rating = 4+
- [ ] Content Rights = no third-party content

### Google Play Console
- [ ] App record created
- [ ] Store listing complete (title, descriptions, icon, feature graphic, screenshots)
- [ ] Content rating questionnaire complete (target: Everyone)
- [ ] Target audience = 13+ (NOT Designed for Families)
- [ ] Privacy policy URL live
- [ ] Data safety form complete
- [ ] Ads declaration = Yes
- [ ] IAPs created with matching product IDs
- [ ] First AAB uploaded to Internal testing
- [ ] Play App Signing enrolled
- [ ] Service account JSON generated, invited as Release Manager, added to Codemagic

### Codemagic
- [ ] Repo connected
- [ ] `admin` App Store Connect integration added
- [ ] `google_play` env var group with `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS` secret
- [ ] Codemagic detects `codemagic.yaml`

---

## 9. First release flow

```bash
# 1. Bump version if you want 1.0.1 — leave as 1.0.0+1 for first release
# 2. Ensure AdMob production IDs are in place (not test IDs)
# 3. Tag and push
git add .
git commit -m "Release v1.0.0"
git tag v1.0.0
git push && git push --tags
```

Codemagic picks up the tag, runs `release-both` workflow:
- iOS IPA → TestFlight (processing takes ~30 min)
- Android AAB → Google Play Production track as DRAFT

From here:
- **iOS:** wait for TestFlight processing → in App Store Connect, add the build to your 1.0.0 version → fill store listing if not already → attach IAPs → **Submit for Review**
- **Android:** Play Console → Production → promote from Internal → Create new release → rollout

**Review times:**
- Apple: 1–3 days typical, up to 7 days for new apps
- Google: 2–7 days for first submission, usually <24h for updates

---

## 10. Assistant instructions

When using this document with a browser-based AI assistant, give it this preamble:

> I'm about to set up a new mobile game called ChromaPulse on both the Apple App Store and Google Play Store, including AdMob ads and in-app purchases. The attached document has all the app identity info, copy, answers to review questionnaires, and step-by-step processes. Walk me through one section at a time, starting with §1 (AdMob). After each section, stop and wait for me to confirm completion before moving on. If any field needs a value I haven't given you, ask me rather than guessing. When filling store forms, always use the exact values from the tables in this document — do not paraphrase product IDs, bundle IDs, or pricing.

Then copy-paste the sections you need help with one at a time.

---

**End of setup guide.** Once you've completed §1 through §5, see [RELEASE.md](RELEASE.md) for the Codemagic-side wiring and the ongoing release workflow.
