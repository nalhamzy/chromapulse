# ChromaPulse 1.2.0 (build 12) - release notes

This repo has no automated "What's new" feed (Codemagic passes none, there is
no fastlane/changelogs). Paste the block below into **Google Play > Release
notes** and **App Store Connect > What's New in This Version**. It is plain
text, English, 405 characters (Play limit 500).

```
New: Progress & history

- Open Stats > Progress & history for a score chart per mode, your average, accuracy and whether you're improving
- Every game is now logged with its date, time, accuracy and average speed
- Tap a mode on the Stats screen to jump straight to its progress
- Your personal-best games are starred
- Doubled scores from rewarded ads now show up in your charts

Keep training your eye!
```

## Internal notes (not for the stores)

- Android: Play Billing Library 8 (`in_app_purchase_android` pinned to 0.5.0),
  target SDK 36. No change to IAP products or prices.
- The chart, average and trend work for existing players straight away (they
  read the score history already stored by 1.1.x). Dated rows and accuracy
  fill in from the first game played on 1.2.0.
- No new permissions, SDKs, accounts or network calls.
