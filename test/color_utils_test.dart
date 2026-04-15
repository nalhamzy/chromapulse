import 'dart:math';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chromapulse/core/utils/color_utils.dart';

void main() {
  group('hslToRgb', () {
    test('pure red', () {
      final c = hslToRgb(0, 100, 50);
      expect((c.r * 255).round(), 255);
      expect((c.g * 255).round(), 0);
      expect((c.b * 255).round(), 0);
    });

    test('pure green', () {
      final c = hslToRgb(120, 100, 50);
      expect((c.r * 255).round(), 0);
      expect((c.g * 255).round(), 255);
      expect((c.b * 255).round(), 0);
    });

    test('pure blue', () {
      final c = hslToRgb(240, 100, 50);
      expect((c.r * 255).round(), 0);
      expect((c.g * 255).round(), 0);
      expect((c.b * 255).round(), 255);
    });

    test('white', () {
      final c = hslToRgb(0, 0, 100);
      expect((c.r * 255).round(), 255);
      expect((c.g * 255).round(), 255);
      expect((c.b * 255).round(), 255);
    });

    test('black', () {
      final c = hslToRgb(0, 0, 0);
      expect((c.r * 255).round(), 0);
      expect((c.g * 255).round(), 0);
      expect((c.b * 255).round(), 0);
    });

    test('grey', () {
      final c = hslToRgb(0, 0, 50);
      expect((c.r * 255).round(), 128);
      expect((c.g * 255).round(), 128);
      expect((c.b * 255).round(), 128);
    });
  });

  group('rgbDistance', () {
    const black = Color(0xFF000000);
    const white = Color(0xFFFFFFFF);
    const red = Color(0xFFFF0000);

    test('same color has distance 0', () {
      expect(rgbDistance(red, red), closeTo(0, 1e-6));
    });

    test('symmetric', () {
      expect(rgbDistance(black, white), closeTo(rgbDistance(white, black), 1e-6));
    });

    test('black-to-white is max', () {
      expect(rgbDistance(black, white), closeTo(sqrt(3) * 255, 1e-6));
    });
  });

  group('rgbAccuracy', () {
    const black = Color(0xFF000000);
    const white = Color(0xFFFFFFFF);
    const red = Color(0xFFFF0000);

    test('identical returns 1.0', () {
      expect(rgbAccuracy(red, red), closeTo(1.0, 1e-6));
    });

    test('black vs white returns 0.0', () {
      expect(rgbAccuracy(black, white), closeTo(0.0, 1e-6));
    });

    test('stays within [0,1]', () {
      final a = rgbAccuracy(black, red);
      expect(a, greaterThanOrEqualTo(0.0));
      expect(a, lessThanOrEqualTo(1.0));
    });
  });

  group('randInt', () {
    test('inclusive bounds', () {
      final rng = Random(42);
      for (var i = 0; i < 1000; i++) {
        final v = randInt(rng, 5, 10);
        expect(v, greaterThanOrEqualTo(5));
        expect(v, lessThanOrEqualTo(10));
      }
    });
  });

  group('shuffleInPlace', () {
    test('preserves elements', () {
      final list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
      final original = List.of(list);
      shuffleInPlace(list, Random(42));
      expect(list.length, original.length);
      expect(list.toSet(), original.toSet());
    });
  });
}
