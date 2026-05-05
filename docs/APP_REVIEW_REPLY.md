# App Store Connect — reviewer reply (Guideline 2.1)

> **Active rejection (April 26, 2026 — submission 816beed1):** ATT
> follow-up. See *§0 ATT follow-up reply* below — that is the only
> section to send this round. Sections 1–6 are kept for reference and
> for future submissions.

---

## 0. ATT follow-up reply (use this round)

### What changed in the binary

- Removed `NSUserTrackingUsageDescription` from `ios/Runner/Info.plist`.
- Bumped version to **1.0.2 (build 5)**.
- Confirmed nothing in the Dart codebase imports
  `app_tracking_transparency` or calls `requestTrackingAuthorization` —
  the previous build's plist key was leftover scaffold boilerplate that
  never had a corresponding code path.

### What to do in App Store Connect (before replying)

1. Upload build **1.0.2 (5)** and select it on the version page.
2. **App Privacy** (left sidebar, requires Account Holder / Admin):
   - Edit data types → confirm **"Data Not Collected"** for the app, or
     equivalently that no data is linked to the user and **no data is
     used for tracking**.
   - Save and publish the updated privacy declaration.
3. Reply to the reviewer message with the text in the next block, and
   attach the new screen recording (script in §1 below — record on a
   freshly installed build so the absence of the ATT prompt is visible).

### Paste this into the App Review reply

```
Thank you for the follow-up.

ChromaPulse does not track users. The previous build (1.0.1, build 4)
declared NSUserTrackingUsageDescription in Info.plist as leftover
scaffold boilerplate, but the app never calls
requestTrackingAuthorization and does not link any user or device data
with third-party data for advertising purposes.

In response to this review:

  1. We removed NSUserTrackingUsageDescription from Info.plist. The new
     build 1.0.2 (5) does not declare the AppTrackingTransparency
     framework and does not present an ATT prompt.

  2. We have updated App Privacy in App Store Connect to reflect that
     ChromaPulse does not collect data and does not use any data for
     tracking.

  3. Google AdMob is configured to run with personalized ads disabled.
     Attribution is handled via SKAdNetwork only; the IDFA is not
     accessed.

The attached screen recording was captured on a physical device after a
fresh install of build 1.0.2 (5). It shows app launch with no ATT
prompt, followed by the typical user flow through all four game modes,
the rewarded ad on the result screen, the Shop with the two
non-consumable in-app purchases, and the Stats dashboard. The app
displays no system permission prompts of any kind.

Please re-review build 1.0.2 (5).
```

---

## 1. Screen recording (attach separately)

Apple requires a real-device recording. Record this on an iPhone or iPad
(the latest rejection was reviewed on iPadOS 26.4.1 — match that if
possible) using the built-in Screen Recording. ~60 seconds.

**Device:** any physical iPhone or iPad running the **build 1.0.2 (5)**
TestFlight install.

**Pre-recording setup (critical for this round):**

- Delete any prior install of ChromaPulse from the device.
- Settings → Privacy & Security → Tracking → toggle "Allow Apps to
  Request to Track" **on** (so the OS would surface a prompt if the app
  asked — proving the app intentionally does not).
- Reinstall ChromaPulse from TestFlight.

**Shot list (in order):**

1. Show the iOS Home Screen, then tap the ChromaPulse icon — show the
   app launching from a fresh install. **No ATT prompt appears.** Hold
   on the main menu for ~2 s so the absence of the prompt is unambiguous.
2. Main menu → tap **Shade Hunter** → play one round (~5 s).
3. Back to menu → tap **Odd Chroma** → play one round.
4. Back to menu → tap **Chroma Recall** → play one round.
5. Back to menu → tap **Color Alchemist** → drag the R/G/B sliders, submit.
6. From the result screen, tap **WATCH AD — DOUBLE SCORE** → rewarded ad
   plays → dismiss → show doubled score.
7. Back to menu → tap **Stats** → show stats dashboard.
8. Back to menu → tap **Shop** → tap **Remove Ads** → show sandbox purchase
   sheet → cancel (or complete with a sandbox tester).

Do **not** include: account creation, login, account deletion, UGC, content
reporting, or any location/contacts/camera/microphone prompts — the app has
none of those. The app does not display any system permission prompts.

Export the recording as .mov or .mp4 (≤ 500 MB) and attach to the App
Review message reply.

---

## 2–6. Paste this into the Notes field

```
App purpose
-----------
ChromaPulse is a casual color-vision training game. It helps designers,
artists, photographers, and curious users sharpen their eye for hue, shade,
and RGB mixing through four bite-sized modes: Shade Hunter, Odd Chroma,
Chroma Recall, and Color Alchemist. The value is quick, repeatable practice
(2-minute sessions) that measurably improves color perception, with
persistent best scores and stats to track progress. It is free to play
with no forced signup, no subscriptions, and no paywalls blocking content.

How to review the app
---------------------
No login or credentials are required. The app has no account system, no
server backend, and no user-generated content. All data (stats, best
scores, purchase entitlements) is stored locally on the device via iOS
UserDefaults (Flutter SharedPreferences).

Main features to review:
  1. Launch app -> main menu shows four game modes plus Stats and Shop.
  2. Tap any mode tile to start a round. Adaptive difficulty and a combo
     multiplier kick in automatically.
  3. On any result screen, "WATCH AD — DOUBLE SCORE" triggers a Google
     AdMob rewarded ad. Reward is granted when the ad completes.
  4. Tap "Shop" from the menu to see the two in-app purchases:
       - chromapulse_remove_ads (non-consumable, USD 1.99) - removes
         banner and interstitial ads.
       - chromapulse_vip_pass    (non-consumable, USD 4.99) - removes
         ads and unlocks future bonus content.
     Both can be validated with any sandbox tester account. There are no
     auto-renewable subscriptions. A "Restore Purchases" button is
     available in the Shop.
  5. Tap "Stats" to see games played, total points, accuracy, and
     per-mode best scores.

The app does not display any system permission prompts. It does not
request camera, microphone, location, contacts, photos, tracking, or any
other sensitive capability. Google AdMob runs in non-personalized /
SKAdNetwork-only mode, so no IDFA access and no ATT prompt are needed.

External services used
----------------------
  - Google AdMob (Google LLC) - banner, interstitial, and rewarded ads.
    Attribution via SKAdNetwork only; no third-party SDKs beyond AdMob.
  - Apple StoreKit (Apple Inc.) - processes both in-app purchases on iOS.

No authentication provider, no analytics SDK, no crash reporter, no
backend API, no AI service, no payment processor outside StoreKit, and no
cloud storage are used.

Regional differences
--------------------
None. ChromaPulse behaves identically in every App Store region. All
four game modes, both in-app purchases, rewarded ads, and all UI strings
are available worldwide. Currency and localized pricing are handled by
App Store Connect tiers; the app itself contains no region-gated
features, region-locked content, or region-specific legal flows.

Regulated industry
------------------
Not applicable. ChromaPulse is a casual puzzle game. It is not a medical
device, does not diagnose or treat any condition (including color
blindness - the app uses "color eye test" only as a consumer term for a
color-perception game), does not provide financial, legal, health, or
educational services, and does not handle any regulated content. No
credentials or authorization documentation are required.

Contact
-------
Developer: Ideal AI
Email: nalhamzy@gmail.com
Support URL: https://github.com/nalhamzy/chromapulse
Privacy Policy: https://nalhamzy.github.io/chromapulse/privacy.html
```

---

## After first approval

Move the body of items 2–6 into the permanent **App Review Information →
Notes** field on the version page so every future submission ships with
it. Update the version-specific bits (rewarded-ad feature, new modes,
etc.) as the app evolves.
