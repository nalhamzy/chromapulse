import 'package:shared_preferences/shared_preferences.dart';
import 'package:chromapulse/core/models/player_stats.dart';

class StorageService {
  static const _key = 'chromaPulseState';
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  PlayerStats load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return const PlayerStats();
    return PlayerStats.decode(raw);
  }

  Future<void> save(PlayerStats stats) async {
    await _prefs.setString(_key, stats.encode());
  }
}
