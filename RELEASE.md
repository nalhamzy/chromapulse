# ChromaPulse — Release & Deployment Guide

End-to-end walkthrough for shipping ChromaPulse to the **Apple App Store** and **Google Play Store** via **Codemagic** CI.

**App identity:**
- Bundle ID (iOS): `com.idealai.chromapulse`
- Application ID (Android): `com.idealai.chromapulse`
- Display name: `ChromaPulse`
- Version source of truth: `pubspec.yaml` → `version: 1.0.0+1` (name + build number)

---

## 0. One-time prerequisites

Before your first release you need accounts and records in four places:

| System | What you need | Link |
|---|---|---|
| Apple Developer | Paid Apple Developer Program membership ($99/yr) | https://developer.apple.com/programs |
| Google Play | Paid Google Play Developer account ($25 one-time) | https://play.google.com/console/signup |
| AdMob | Free AdMob account linked to a Google account | https://admob.google.com |
| Codemagic | Free tier is fine for low-volume builds | https://codemagic.io |

---

## 1. App Store Connect setup (iOS)

### 1.1 Create the app record

1. Go to https://appstoreconnect.apple.com → **My Apps** → **+** → **New App**.
2. Fill in:
   - **Platform:** iOS
   - **Name:** `ChromaPulse` (this is the App Store name — must be unique globally; have 2–3 alternates ready)
   - **Primary Language:** English (U.S.)
   - **Bundle ID:** select `com.idealai.chromapulse` (create it first under Certificates, Identifiers & Profiles → Identifiers if it doesn't appear)
   - **SKU:** `chromapulse-ios-001` (internal, your choice)
   - **User Access:** Full Access
3. Click **Create**.

### 1.2 Register the Bundle ID (if not already done)

1. https://developer.apple.com/account/resources/identifiers/list → **+**
2. Select **App IDs** → **App**
3. Description: `ChromaPulse iOS`
4. Bundle ID: **Explicit** → `com.idealai.chromapulse`
5. Capabilities: enable **In-App Purchase**
6. Register.

### 1.3 Category, age rating, privacy

In App Store Connect → your app → **App Information**:
- **Category:** Games → Puzzle (primary). Optional secondary: Games → Casual.
- **Age Rating:** answer questionnaire → should come out to **4+**.
- **⚠ DO NOT opt into the Kids Category** (lesson from color_chaos). The "Made for Kids" toggle stays **off**.

In **App Privacy** → **Get Started**:
- Declare: Identifiers (AdMob advertising ID for Google AdMob), Usage Data (AdMob).
- If you ship without analytics: declare only what AdMob collects.

### 1.4 In-App Purchases

ChromaPulse ships with two non-consumable IAPs. Both need to be configured **before** your first submission, with review screenshots attached.

Under **In-App Purchases** → **+** for each:

| Product ID (must match code exactly) | Reference Name | Type | Suggested Price |
|---|---|---|---|
| `remove_ads` | Remove Ads | Non-Consumable | $1.99 (Tier 2) |
| `vip_pass` | VIP Pass | Non-Consumable | $4.99 (Tier 5) |

For each product:
- Add at least one localization (English) with **Display Name** and **Description**.
- Upload a **Review Screenshot** (minimum 640×920; a 1290×2796 capture of the ChromaPulse shop screen works great).
- In **Review Notes**, add: *"ChromaPulse non-consumable upgrade. Unlocked by tapping this tile in the in-app shop. Can be validated in sandbox with any tester account."*
- **Save** and ensure status flips to **"Ready to Submit"** (yellow is OK until attached to a build).

⚠ **Critical lesson from color_chaos:** IAPs that are "Ready to Submit" but **not attached to a specific app version** are invisible to StoreKit in TestFlight and Production. During your first submission, attach them on the Version page → **In-App Purchases and Subscriptions** section.

### 1.5 Paid Apps Agreement

**Agreements, Tax, and Banking** → **Paid Apps** must be **Active** (status bar says so).

If you see "Pending" or "Action Required", IAPs will return empty from StoreKit in production/TestFlight (sandbox will still work — this is the silent killer). Complete the tax forms and banking info before release.

### 1.6 App Store Connect API Key for Codemagic

This key is what Codemagic uses to upload to TestFlight and manage certificates.

1. **Users and Access** → **Keys** → **+**
2. **Name:** `Codemagic Upload`
3. **Access:** **App Manager** (you can scope to specific apps later)
4. Download the `.p8` file **immediately** (Apple only lets you download it once)
5. Note the **Issuer ID** and **Key ID**

---

## 2. Android signing setup

Google Play requires a signed AAB. You'll generate an **upload keystore** locally — this is what you use to sign uploads. Google then re-signs with their **app signing key** (managed by Play App Signing).

### 2.1 Generate the keystore

Run this locally (Windows PowerShell / Git Bash):

```bash
cd android/app
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Fill in the prompts (use your real legal name / org when asked). Remember the store password and key password — put them in `key.properties`.

### 2.2 Create `key.properties`

Copy the template and fill in real values:

```bash
cp android/key.properties.template android/key.properties
```

Edit `android/key.properties`:

```
storePassword=your_real_store_password
keyPassword=your_real_key_password
keyAlias=upload
storeFile=upload-keystore.jks
```

✅ **Commit both `key.properties` AND `upload-keystore.jks` to your git repo** (see `.gitignore` — they are intentionally NOT ignored). The upload keystore is NOT the app signing key; Google Play re-signs apps with its own key. If your upload keystore leaks, you can rotate it; if you LOSE it, recovering access requires contacting Google support.

### 2.3 Verify local release build

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

---

## 3. Google Play Console setup

### 3.1 Create the app record

1. https://play.google.com/console → **Create app**
2. Fill in:
   - **App name:** `ChromaPulse`
   - **Default language:** English (United States) – en-US
   - **App or game:** Game
   - **Free or paid:** Free (monetized via in-app purchases and ads)
3. Accept declarations (Designed for Families: **No** — same lesson as Apple Kids Category).
4. Click **Create app**.

### 3.2 App content declarations

Under **Policy** → **App content**, complete:
- **Privacy policy:** you need a public URL (Google requires one because the app uses AD_ID). Put it in a gist, GitHub Pages, or free static host.
- **App access:** all features available without restrictions
- **Ads:** **Yes, my app contains ads**
- **Content rating:** fill the IARC questionnaire → ChromaPulse should come out to **Everyone**
- **Target audience:** age 13+ (not children)
- **News app:** No
- **COVID-19 contact tracing:** No
- **Data safety:** declare AdMob advertising ID collection

### 3.3 In-App Products

Under **Monetize** → **Products** → **In-app products**:

Create both products with IDs matching the code exactly:

| Product ID | Name | Description | Price |
|---|---|---|---|
| `remove_ads` | Remove Ads | Hide all banner and interstitial ads forever. | $1.99 |
| `vip_pass` | VIP Pass | Removes ads and unlocks future bonus content. | $4.99 |

Each product status must be **Active**.

### 3.4 Upload your first AAB to Internal Testing

Google Play requires at least one uploaded AAB before it lets you configure many things.

1. **Testing** → **Internal testing** → **Create new release**
2. Drag in the `app-release.aab` from `build/app/outputs/bundle/release/`
3. Enroll in **Play App Signing** when prompted (required, one-time, irrevocable). Google generates and stores the real signing key — you keep only the upload key.
4. Add a release name (e.g. `1.0.0 (1)`) and release notes.
5. Save → Review → Rollout to Internal testing.
6. Add yourself as an internal tester under **Testers** tab.

### 3.5 Google Play service account for Codemagic

Codemagic uses a service account to upload and publish AABs.

1. Go to https://console.cloud.google.com → create a new project (or reuse one).
2. **IAM & Admin** → **Service Accounts** → **+ CREATE SERVICE ACCOUNT**
   - Name: `codemagic-publisher`
   - Grant: no project-level role needed (permissions granted in Play Console)
   - Skip the "Grant users access" step.
3. Open the new account → **Keys** → **Add Key** → **Create new key** → JSON. Download the file.
4. In Play Console → **Users and permissions** → **Invite new users** (email is the service account email, ends with `@your-project.iam.gserviceaccount.com`).
5. App permissions: give **Release manager** role for the ChromaPulse app.
6. Accept the invite.

---

## 4. Codemagic wiring

The `codemagic.yaml` already committed to the repo defines three workflows (`release-both`, `ios-release`, `android-release`). You just need to connect secrets.

### 4.1 Connect your repo

1. https://codemagic.io/apps → **Add application** → connect your GitHub account → select the ChromaPulse repo
2. Codemagic detects `codemagic.yaml` automatically.

### 4.2 App Store Connect integration

1. Codemagic → **Teams** → your team → **Integrations** → **Apple Developer Portal** → **Add**
2. Name: **admin** (must match `integrations: app_store_connect: admin` in `codemagic.yaml`)
3. Paste:
   - **Issuer ID** (from step 1.6)
   - **Key ID** (from step 1.6)
   - Upload the `.p8` private key file
4. Save.

### 4.3 Google Play service account secret

1. Codemagic → **Teams** → your team → **Environment variables**
2. Create group: `google_play` (matches `groups: [google_play]` in `codemagic.yaml`)
3. Add variable:
   - **Name:** `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS`
   - **Value:** paste the entire JSON contents of the service account key from step 3.5
   - ✅ **Secure** (mask in logs)

### 4.4 Code signing (iOS)

Codemagic's `xcode-project use-profiles` step auto-manages certificates and provisioning profiles via the App Store Connect API key. You don't need to upload anything manually — the integration handles it.

On the first run, Codemagic creates:
- An `Apple Distribution` certificate (if missing)
- An `App Store` provisioning profile for `com.idealai.chromapulse`

### 4.5 Trigger a release

```bash
# Bump version in pubspec.yaml first, e.g. 1.0.1+2
git commit -am "Release v1.0.1"
git tag v1.0.1
git push && git push --tags
```

Codemagic detects the `v*` tag and runs `release-both`. Watch the build at https://codemagic.io/apps → your app → Builds.

Expected output:
- iOS IPA uploaded to **TestFlight** (~30 min processing before it appears in TestFlight UI)
- Android AAB uploaded to **Google Play Production track as DRAFT** (you manually promote to rollout)
- Email notification to `nalhamzy@gmail.com` on success/failure

---

## 5. Submitting for review

### 5.1 iOS TestFlight → App Store

1. Once the build appears in App Store Connect → TestFlight, add it to the **App Store** version.
2. Fill in store listing (screenshots, description, keywords, support URL, privacy policy URL).
3. **Screenshots required:**
   - iPhone 6.9" (1290 × 2796) — **required**
   - iPhone 6.5" — optional fallback
   - iPad 13" (2064 × 2752) — **required if you support iPad**
   - Use the iOS Simulator at exact sizes. iPhone 15 Pro Max simulator → Cmd+S gives you 1290×2796 natively.
4. Under **In-App Purchases and Subscriptions** on the version page, click **+** and attach `remove_ads` + `vip_pass` to this build.
5. **Submit for Review**.

**⚠ Avoid these rejection traps (learned from color_chaos):**
- Do NOT mark the app as "Made for Kids" — it triggers the Kids Category contextual-ads requirement.
- Screenshots must show **actual app UI in use** for the majority of captures. Splash/menu screens don't count as "app in use."
- iPad screenshots must show the iPad-layout UI (not a phone-column centered on a big canvas). ChromaPulse's `ResponsiveContentBox` + `context.s()` scaling handles this by construction.

### 5.2 Google Play: promote to Production

1. Play Console → **Testing** → **Internal testing** → verify the latest release works for you.
2. **Production** → **Create new release** → **Promote from Internal testing** → pick the release.
3. Add release notes.
4. **Review release** → **Start rollout to production** (can choose staged rollout %).
5. First submission triggers a human review — takes 2–7 days for new apps.

---

## 6. Post-launch checklist

- [ ] Replace AdMob test unit IDs with real ones in [lib/core/constants/ad_ids.dart](lib/core/constants/ad_ids.dart) `_prod*` constants.
- [ ] Replace AdMob test app ID in [android/app/src/main/AndroidManifest.xml](android/app/src/main/AndroidManifest.xml) (`com.google.android.gms.ads.APPLICATION_ID`) with your real AdMob Android app ID.
- [ ] Replace AdMob test app ID in [ios/Runner/Info.plist](ios/Runner/Info.plist) (`GADApplicationIdentifier`) with your real AdMob iOS app ID.
- [ ] Expand the `SKAdNetworkItems` array in Info.plist with the full list Google publishes for AdMob (needed for accurate SKAdNetwork attribution on iOS 14.5+): https://developers.google.com/admob/ios/3p-skadnetworks
- [ ] Design and ship a real app icon: place a 1024×1024 PNG at `assets/icon/icon_source.png` and run `dart run flutter_launcher_icons`.
- [ ] Capture store screenshots on iPhone 15 Pro Max and iPad Pro 13" simulators + real Android devices.
- [ ] Write the privacy policy and host it publicly; paste URL into both App Store Connect and Google Play.
- [ ] Smoke-test sandbox purchases on both platforms before first tag.

---

## 7. Troubleshooting

**"No matching provisioning profile" on Codemagic iOS build**
→ The App Store Connect API key in Codemagic has the wrong role. It needs **App Manager** or higher. Also verify the Bundle ID is registered in the developer portal.

**"Upload failed: version code already used" on Google Play**
→ Bump the build number. `pubspec.yaml` → increment the number after `+`, e.g. `1.0.1+2` → `1.0.1+3`.

**IAPs return empty in TestFlight (but work in sandbox)**
→ One of three things: (a) Paid Apps Agreement not Active, (b) IAPs not attached to the app version, (c) first-ever submission hasn't been approved yet (IAPs get approved as a bundle with the first binary).

**Android build fails locally with `key.properties` missing**
→ Expected in fresh clones. Copy `android/key.properties.template` → `android/key.properties` and fill in. Or just use `flutter build apk --debug` for local testing.

**"Store not available" SnackBar in the shop**
→ Sandbox/TestFlight only: IAPs haven't been approved yet. Production: Paid Apps Agreement inactive OR product IDs mismatch between `lib/core/services/iap_product_ids.dart` and the store product ID strings.

---

## 8. Version bumping cheat-sheet

```bash
# 1. Edit pubspec.yaml: version: 1.0.1+2  (name+buildNumber)
# 2. Commit + tag + push
git commit -am "Release v1.0.1"
git tag v1.0.1
git push && git push --tags
```

Semantic scheme:
- **Patch** (1.0.0 → 1.0.1): bug fixes only
- **Minor** (1.0.0 → 1.1.0): new features, backward-compatible
- **Major** (1.0.0 → 2.0.0): breaking changes, redesigns

Always bump the build number (`+N`) even for patches — Google Play and App Store Connect require it to be monotonically increasing per bundle ID.
