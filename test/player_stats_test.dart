import 'package:flutter_test/flutter_test.dart';
import 'package:chromapulse/core/models/player_stats.dart';

void main() {
  group('PlayerStats JSON round-trip', () {
    test('default stats encode/decode losslessly', () {
      const original = PlayerStats();
      final decoded = PlayerStats.decode(original.encode());
      expect(decoded, original);
    });

    test('all v1.1 fields survive a round-trip', () {
      final original = PlayerStats(
        totalGames: 12,
        totalScore: 4321,
        totalCorrect: 50,
        totalRounds: 60,
        bestByMode: const {'shade': 800, 'odd': 920},
        adsRemoved: true,
        vip: true,
        soundEnabled: false,
        hapticsEnabled: false,
        lastDailyDate: '2026-05-04',
        currentStreak: 7,
        longestStreak: 14,
        unlockedAchievements: const {'first_pulse', 'daily_dose'},
        recentScoresByMode: const {
          'shade': [800, 600, 400],
          'odd': [920],
        },
        rewardedAdsWatched: 3,
        sharesCount: 2,
      );
      final decoded = PlayerStats.decode(original.encode());
      expect(decoded, original);
    });

    test('legacy v1.0 JSON decodes with default v1.1 fields', () {
      const legacy = '{'
          '"totalGames":3,'
          '"totalScore":150,'
          '"totalCorrect":10,'
          '"totalRounds":12,'
          '"bestByMode":{"shade":80},'
          '"adsRemoved":false,'
          '"vip":false,'
          '"soundEnabled":true'
          '}';
      final decoded = PlayerStats.decode(legacy);
      expect(decoded.totalGames, 3);
      expect(decoded.bestByMode['shade'], 80);
      expect(decoded.hapticsEnabled, true);
      expect(decoded.currentStreak, 0);
      expect(decoded.lastDailyDate, isNull);
      expect(decoded.unlockedAchievements, isEmpty);
      expect(decoded.recentScoresByMode, isEmpty);
      expect(decoded.rewardedAdsWatched, 0);
      expect(decoded.sharesCount, 0);
    });

    test('garbage decodes to default stats', () {
      expect(PlayerStats.decode('not json {{{'), const PlayerStats());
    });
  });
}
