import 'package:flutter/services.dart';

/// Thin wrapper around [HapticFeedback] with a runtime enable flag so the
/// player can disable haptics globally from settings.
class HapticService {
  bool _enabled = true;

  bool get enabled => _enabled;
  void setEnabled(bool v) => _enabled = v;

  Future<void> tap() async {
    if (!_enabled) return;
    await HapticFeedback.selectionClick();
  }

  Future<void> light() async {
    if (!_enabled) return;
    await HapticFeedback.lightImpact();
  }

  Future<void> success() async {
    if (!_enabled) return;
    await HapticFeedback.mediumImpact();
  }

  Future<void> error() async {
    if (!_enabled) return;
    await HapticFeedback.heavyImpact();
  }

  Future<void> celebrate() async {
    if (!_enabled) return;
    // Sequence of two pulses for achievement / new-best moments.
    await HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 90));
    await HapticFeedback.heavyImpact();
  }
}
