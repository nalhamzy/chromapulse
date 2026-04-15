import 'dart:convert';
import 'package:equatable/equatable.dart';

class PlayerStats extends Equatable {
  final int totalGames;
  final int totalScore;
  final int totalCorrect;
  final int totalRounds;
  final Map<String, int> bestByMode;
  final bool adsRemoved;
  final bool vip;
  final bool soundEnabled;

  const PlayerStats({
    this.totalGames = 0,
    this.totalScore = 0,
    this.totalCorrect = 0,
    this.totalRounds = 0,
    this.bestByMode = const {},
    this.adsRemoved = false,
    this.vip = false,
    this.soundEnabled = true,
  });

  int bestFor(String modeId) => bestByMode[modeId] ?? 0;

  int get accuracyPct =>
      totalRounds > 0 ? ((totalCorrect / totalRounds) * 100).round() : 0;

  PlayerStats copyWith({
    int? totalGames,
    int? totalScore,
    int? totalCorrect,
    int? totalRounds,
    Map<String, int>? bestByMode,
    bool? adsRemoved,
    bool? vip,
    bool? soundEnabled,
  }) =>
      PlayerStats(
        totalGames: totalGames ?? this.totalGames,
        totalScore: totalScore ?? this.totalScore,
        totalCorrect: totalCorrect ?? this.totalCorrect,
        totalRounds: totalRounds ?? this.totalRounds,
        bestByMode: bestByMode ?? this.bestByMode,
        adsRemoved: adsRemoved ?? this.adsRemoved,
        vip: vip ?? this.vip,
        soundEnabled: soundEnabled ?? this.soundEnabled,
      );

  Map<String, dynamic> toJson() => {
        'totalGames': totalGames,
        'totalScore': totalScore,
        'totalCorrect': totalCorrect,
        'totalRounds': totalRounds,
        'bestByMode': bestByMode,
        'adsRemoved': adsRemoved,
        'vip': vip,
        'soundEnabled': soundEnabled,
      };

  static PlayerStats fromJson(Map<String, dynamic> j) => PlayerStats(
        totalGames: j['totalGames'] as int? ?? 0,
        totalScore: j['totalScore'] as int? ?? 0,
        totalCorrect: j['totalCorrect'] as int? ?? 0,
        totalRounds: j['totalRounds'] as int? ?? 0,
        bestByMode: (j['bestByMode'] as Map?)
                ?.map((k, v) => MapEntry(k.toString(), (v as num).toInt())) ??
            const {},
        adsRemoved: j['adsRemoved'] as bool? ?? false,
        vip: j['vip'] as bool? ?? false,
        soundEnabled: j['soundEnabled'] as bool? ?? true,
      );

  String encode() => jsonEncode(toJson());

  static PlayerStats decode(String raw) {
    try {
      return fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const PlayerStats();
    }
  }

  @override
  List<Object?> get props => [
        totalGames,
        totalScore,
        totalCorrect,
        totalRounds,
        bestByMode,
        adsRemoved,
        vip,
        soundEnabled,
      ];
}
