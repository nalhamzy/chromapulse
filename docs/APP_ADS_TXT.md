# Fixing the `app-ads.txt` problem for ChromaPulse

If AdMob is reporting **"app-ads.txt not found"** or **"Not authorized"**,
here's the full repair flow.

## What Google expects

AdMob crawls `<Developer website>/app-ads.txt`, where **Developer website**
is the field set in your **Play Store listing** and **App Store Connect**
metadata — NOT some random URL. For ChromaPulse this should be one of:

- `https://nalhamzy.github.io/` — root domain. Simplest.
- `https://nalhamzy.github.io/chromapulse/` — subpath. Only works if
  Google also finds a mirrored file at
  `https://nalhamzy.github.io/chromapulse/app-ads.txt`.

We ship the file in **both** locations now:

- Root: [`nalhamzy.github.io/app-ads.txt`](https://nalhamzy.github.io/app-ads.txt) — served from the `nalhamzy.github.io` repo.
- Subpath (this repo): `docs/app-ads.txt` — served at `https://nalhamzy.github.io/chromapulse/app-ads.txt` once Pages deploys.

## What the file must contain

```
google.com, pub-4401199263287951, DIRECT, f08c47fec0942fa0
```

- `pub-4401199263287951` — our single AdMob publisher ID (shared across
  ChromaPulse, Color Chaos, Silver Suite).
- `DIRECT` — we sell our ad inventory directly; no reseller.
- `f08c47fec0942fa0` — Google's official trust certificate hash.

## Step-by-step fix

1. **Play Console → ChromaPulse → Store listing → Contact details → Website**
   Set it to `https://nalhamzy.github.io/`.
2. **App Store Connect → App Information → Marketing URL**
   Same value: `https://nalhamzy.github.io/`.
3. **AdMob → Apps → ChromaPulse → App settings → app-ads.txt**
   Click **"Verify now"**. You should see "Authorized" within 24 hours.
4. **If still not found after 24 hours**: AdMob sometimes caches the
   "Not found" state. Re-save the Developer website field in Play
   Console (no change needed — just click Save) to nudge the crawler.

## Adding a new mediator later

If you integrate AppLovin / Unity Ads / IronSource:

1. Each provides a record like `applovin.com, xyz, DIRECT`.
2. Append each new line to **both** `nalhamzy.github.io/app-ads.txt`
   AND this file (`chromapulse/docs/app-ads.txt`).
3. Commit + push. Pages deploys in ~60 seconds.
4. Let AdMob re-crawl (automatic every ~24h).

## Verifying locally

```bash
# From the chromapulse_flutter repo root:
cd docs
python -m http.server 8000
# Then open:
# http://localhost:8000/app-ads.txt
# Should render plain text, not the HTML index.
```

## Common reasons for "Not authorized"

| Symptom | Fix |
|---|---|
| File is HTML, not plain text | Rename wasn't done correctly; must be `app-ads.txt` literally |
| Served as `application/octet-stream` | GitHub Pages does this correctly by default — don't override MIME |
| Record has Windows line endings (`\r\n`) | Normalize to LF |
| Extra BOM at start of file | Re-save as UTF-8 without BOM |
| Publisher ID typo | Must match the AdMob-generated publisher ID exactly |
| DNS not resolving | `nalhamzy.github.io` is a GitHub-managed subdomain — always resolves |
