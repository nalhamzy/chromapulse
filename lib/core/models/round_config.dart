import 'package:flutter/painting.dart';

/// Output of a mode-specific round builder. Immutable plain struct.
class RoundConfig {
  final List<Color> cells;        // empty for alchemist
  final int targetIndex;          // -1 for alchemist
  final int gridColumns;          // 3 or 4
  final String instruction;
  final int timeLimitMs;
  final Color? memoryTarget;      // recall phase only
  final int memoryShowMs;         // recall only
  final Color? blendTarget;       // alchemist only

  const RoundConfig({
    this.cells = const [],
    this.targetIndex = -1,
    this.gridColumns = 3,
    required this.instruction,
    required this.timeLimitMs,
    this.memoryTarget,
    this.memoryShowMs = 0,
    this.blendTarget,
  });
}
