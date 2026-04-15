import 'dart:math' as math;
import 'package:flutter/painting.dart';

/// HSL → RGB converter (port of the HTML prototype).
///
/// [h] in `[0, 360)`, [s] and [l] in `[0, 100]`.
/// Returns a fully-opaque Flutter [Color].
Color hslToRgb(double h, double s, double l) {
  final sN = s / 100;
  final lN = l / 100;
  double k(double n) => (n + h / 30) % 12;
  final a = sN * math.min(lN, 1 - lN);
  double f(double n) =>
      lN - a * math.max(-1, math.min(k(n) - 3, math.min(9 - k(n), 1.0)));
  final r = (f(0) * 255).round().clamp(0, 255);
  final g = (f(8) * 255).round().clamp(0, 255);
  final b = (f(4) * 255).round().clamp(0, 255);
  return Color.fromARGB(255, r, g, b);
}

/// Euclidean distance in RGB space between two fully-opaque colors.
double rgbDistance(Color a, Color b) {
  final dr = (a.r * 255 - b.r * 255);
  final dg = (a.g * 255 - b.g * 255);
  final db = (a.b * 255 - b.b * 255);
  return math.sqrt(dr * dr + dg * dg + db * db);
}

/// Normalised accuracy in `[0, 1]` where `1.0` is a perfect match.
double rgbAccuracy(Color a, Color b) {
  const maxDist = 441.6729559300637; // sqrt(3) * 255
  final d = rgbDistance(a, b);
  return math.max(0.0, 1.0 - d / maxDist);
}

/// Inclusive random integer in `[min, max]`.
int randInt(math.Random rng, int min, int max) =>
    min + rng.nextInt(max - min + 1);

/// Uniform double in `[min, max)`.
double randDouble(math.Random rng, double min, double max) =>
    min + rng.nextDouble() * (max - min);

/// In-place Fisher-Yates shuffle.
void shuffleInPlace<T>(List<T> list, math.Random rng) {
  for (var i = list.length - 1; i > 0; i--) {
    final j = rng.nextInt(i + 1);
    final t = list[i];
    list[i] = list[j];
    list[j] = t;
  }
}
