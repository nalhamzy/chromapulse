import 'package:flutter/widgets.dart';
import 'package:chromapulse/core/constants/app_colors.dart';

enum GameMode {
  shadeHunter(
    id: 'shade',
    label: 'Shade Hunter',
    iconGlyph: '◐',
    description:
        'Find the darkest or lightest shade among increasingly similar colors.',
    accent: AppColors.accent,
    totalRounds: 10,
    defaultTimeLimitMs: 5000,
    hasGrid: true,
  ),
  oddChroma(
    id: 'odd',
    label: 'Odd Chroma',
    iconGlyph: '◈',
    description:
        'One tile is a slightly different hue. Spot the impostor as it shrinks.',
    accent: AppColors.accent3,
    totalRounds: 10,
    defaultTimeLimitMs: 5000,
    hasGrid: true,
  ),
  chromaRecall(
    id: 'memory',
    label: 'Chroma Recall',
    iconGlyph: '◉',
    description:
        'A target flashes briefly. Remember it and pick from near-identical shades.',
    accent: AppColors.accent2,
    totalRounds: 10,
    defaultTimeLimitMs: 5000,
    hasGrid: true,
  ),
  colorAlchemist(
    id: 'blend',
    label: 'Color Alchemist',
    iconGlyph: '◎',
    description: 'Mix RGB sliders to recreate the target color.',
    accent: AppColors.gold,
    totalRounds: 8,
    defaultTimeLimitMs: 12000,
    hasGrid: false,
  ),
  paletteMatch(
    id: 'palette',
    label: 'Palette Match',
    iconGlyph: '◇',
    description:
        'VIP — Recreate a 4-swatch palette from a noisy 9-tile grid before time runs out.',
    accent: AppColors.silver,
    totalRounds: 8,
    defaultTimeLimitMs: 12000,
    hasGrid: false,
    vipOnly: true,
  );

  final String id;
  final String label;
  final String iconGlyph;
  final String description;
  final Color accent;
  final int totalRounds;
  final int defaultTimeLimitMs;
  final bool hasGrid;
  final bool vipOnly;

  const GameMode({
    required this.id,
    required this.label,
    required this.iconGlyph,
    required this.description,
    required this.accent,
    required this.totalRounds,
    required this.defaultTimeLimitMs,
    required this.hasGrid,
    this.vipOnly = false,
  });

  static GameMode? byId(String id) {
    for (final m in values) {
      if (m.id == id) return m;
    }
    return null;
  }
}
