# ChromaPulse — ship v1.0.0 checklist

Everything code-side is done. What's left is console work that only you can do
(Apple/Google/Codemagic web UIs). This is the minimal punch list, in order.

For theory, see [AUTOMATED_RELEASES.md](../color_chaos_flutter/AUTOMATED_RELEASES.md)
(the Color Chaos master doc) or [RELEASE.md](RELEASE.md).

---

## What's already done (don't redo)

- [x] `codemagic.yaml` committed with `com.idealai.chromapulse` everywhere
- [x] AdMob production IDs in place (`android/app/src/main/AndroidManifest.xml`,
      `ios/Runner/Info.plist`, `lib/core/constants/ad_ids.dart`)
- [x] Upload keystore generated → `android/app/upload-keystore.jks`
- [x] `android/key.properties` committed, keystore un-ignored
- [x] Local `flutter build appbundle --release` succeeds (47 MB AAB)
- [x] All store screenshots + listing copy ready in `store_assets/`
- [x] Privacy policy page published at nalhamzy.github.io/chromapulse/privacy.html
      (via commit `c887394`)

---

## 1. App Store Connect — create the app record

Apple side. Required before Codemagic's first iOS build can push to TestFlight.

1. https://developer.apple.com/account/resources/identifiers/list → **+** →
   App IDs → App → Description `ChromaPulse iOS`, Bundle ID explicit
   `com.idealai.chromapulse`, enable **In-App Purchase**. Register.
2. https://appstoreconnect.apple.com → My Apps → **+ New App** →
   iOS, name `ChromaPulse: Color Eye Test`, bundle `com.idealai.chromapulse`,
   SKU `chromapulse-ios-001`.
3. Fill Name / Subtitle / Promo / Keywords / Description from
   [store_assets/LISTING_COPY.md](store_assets/LISTING_COPY.md) — **Save as draft**.
4. Add 2 IAPs (`remove_ads` $1.99, `vip_pass` $4.99) — non-consumable —
   using copy from the same file.
5. Confirm **Paid Apps Agreement = Active** in Agreements, Tax, Banking.
6. Skip "Submit for Review" for now.

---

## 2. Google Play Console — create the app record

1. https://play.google.com/console → **Create app** → name
   `ChromaPulse: Color Eye Test`, lang en-US, Game, Free.
2. Fill Store listing + App content declarations using
   [LISTING_COPY.md](store_assets/LISTING_COPY.md).
3. Create both IAPs (`remove_ads` $1.99, `vip_pass` $4.99) under **Monetize →
   Products → In-app products**.
4. **Build first AAB and upload manually** — Google requires this before the
   API can publish:
   ```bash
   cd C:/Users/PC/Documents/GitHub/Ideas/chromapulse_flutter
   flutter build appbundle --release
   # AAB is already built at build/app/outputs/bundle/release/app-release.aab
   ```
   Then Play Console → **Internal testing → Create new release** → drag the
   AAB → enroll in Play App Signing → rollout.
5. Invite the existing service account email (the one attached to the
   `google_play` Codemagic group — looks like
   `codemagic-publisher@PROJECT.iam.gserviceaccount.com`) as **Release Manager**
   under Users and permissions.

---

## 3. Codemagic — add the app

Team-level integrations (`admin` ASC key, `google_play` env group) are already
in place from Color Chaos / Drift. Per-app work:

1. https://codemagic.io/apps → **Add application** → connect GitHub
   `nalhamzy/chromapulse`.
2. App **Settings** → switch from Workflow Editor to **codemagic.yaml**.
3. Verify it sees the 3 workflows from the yaml (`release-both`,
   `ios-release`, `android-release`).

That's it — no credentials to enter since `admin` and `google_play` are
team-level.

---

## 4. Tag and ship

```bash
cd C:/Users/PC/Documents/GitHub/Ideas/chromapulse_flutter
git tag v1.0.0
git push origin master --tags
```

Codemagic detects the `v*` tag → runs `release-both` → uploads IPA to
TestFlight + AAB to Play Production (as draft).

Watch at https://codemagic.io/apps → ChromaPulse → Builds. ~30 min.

---

## 5. Post-build

- **iOS:** App Store Connect → TestFlight → once the build appears, attach
  it to your 1.0.0 version → attach both IAPs under "In-App Purchases and
  Subscriptions" on the version page → **Submit for Review**.
- **Android:** Play Console → Production → Create new release → Promote from
  Internal testing → rollout.

Review times: Apple 1–3 days, Google 2–7 days for first submission.

---

## Rollback / re-build

If the first Codemagic run fails:

```bash
# Fix the issue, bump pubspec.yaml to 1.0.0+2, then:
git commit -am "Fix"
git tag v1.0.0-2
git push origin master --tags
```

Never re-push the same tag — both stores reject duplicate build numbers.
