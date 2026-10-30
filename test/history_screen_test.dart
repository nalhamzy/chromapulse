import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chromapulse/core/constants/theme.dart';
import 'package:chromapulse/core/models/game_record.dart';
import 'package:chromapulse/core/models/player_stats.dart';
import 'package:chromapulse/core/services/audio_service.dart';
import 'package:chromapulse/providers/audio_provider.dart';
import 'package:chromapulse/providers/history_provider.dart';
import 'package:chromapulse/providers/navigation_provider.dart';
import 'package:chromapulse/providers/player_provider.dart';
import 'package:chromapulse/screens/history_screen.dart';
import 'package:chromapulse/screens/stats_screen.dart';
import 'package:chromapulse/widgets/common/section_card.dart';

/// Serves a fixed profile without touching SharedPreferences.
class _FakePlayer extends PlayerNotifier {
  final PlayerStats initial;
  _FakePlayer(this.initial);

  @override
  PlayerStats build() => initial;
}

/// Taps must not reach the audioplayers platform channel in tests.
class _SilentAudio implements AudioService {
  @override
  bool get enabled => false;

  @override
  void setEnabled(bool v) {}

  @override
  Future<void> play(SoundEffect sfx) async {}

  @override
  Future<void> dispose() async {}
}

final _now = DateTime.now();

GameRecord _rec(String mode, int i, {bool daily = false}) => GameRecord(
  modeId: mode,
  score: 400 + i * 37 % 500,
  correct: 5 + i % 6,
  rounds: 10,
  avgTimeMs: 1500 + i * 120,
  playedAtMs: _now.subtract(Duration(hours: i * 20)).millisecondsSinceEpoch,
  daily: daily,
);

PlayerStats _populated() {
  final shade = [for (var i = 0; i < 24; i++) _rec('shade', i, daily: i == 2)];
  final odd = [for (var i = 0; i < 6; i++) _rec('odd', i)];
  // History interleaves modes, newest first.
  final history = [...shade, ...odd]
    ..sort((a, b) => b.playedAtMs.compareTo(a.playedAtMs));
  return PlayerStats(
    totalGames: 30,
    bestByMode: {
      'shade': shade.map((r) => r.score).reduce((a, b) => a > b ? a : b),
      'odd': odd.map((r) => r.score).reduce((a, b) => a > b ? a : b),
    },
    recentScoresByMode: {
      'shade': shade.map((r) => r.score).toList(),
      'odd': odd.map((r) => r.score).toList(),
    },
    history: history,
  );
}

/// An install that upgraded from 1.1.x: scores exist, dated history does not.
PlayerStats _upgraded() => const PlayerStats(
  totalGames: 5,
  bestByMode: {'shade': 700},
  recentScoresByMode: {
    'shade': [700, 600, 500, 400, 300],
  },
);

Widget _app(
  PlayerStats stats,
  Widget screen, {
  double textScale = 1.0,
  String? focus,
}) {
  return ProviderScope(
    overrides: [
      playerProvider.overrideWith(() => _FakePlayer(stats)),
      audioServiceProvider.overrideWithValue(_SilentAudio()),
      if (focus != null)
        historyFocusProvider.overrideWith(() => _Focused(focus)),
    ],
    child: MaterialApp(
      theme: ThemeData.dark(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: screen,
    ),
  );
}

class _Focused extends HistoryFocusNotifier {
  final String id;
  _Focused(this.id);

  @override
  String? build() => id;
}

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(360, 640);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Future<void> _scrollToEnd(WidgetTester tester) async {
  final list = find.byType(Scrollable).last;
  for (var i = 0; i < 12; i++) {
    await tester.drag(list, const Offset(0, -500));
    await tester.pump();
  }
}

void main() {
  setUpAll(() {
    // Keep google_fonts off the network in tests.
    AppTheme.useGoogleFonts = false;
  });

  group('HistoryScreen at 360x640', () {
    testWidgets('populated profile lays out without overflow', (tester) async {
      _phone(tester);
      await tester.pumpWidget(_app(_populated(), const HistoryScreen()));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('PROGRESS'), findsOneWidget);
      expect(find.text('RECENT GAMES'), findsOneWidget);
      expect(find.textContaining('vs your previous'), findsOneWidget);
      expect(find.text('Shade Hunter'), findsOneWidget);
      expect(find.text('Odd Chroma'), findsOneWidget);
      // Modes never played get no chip.
      expect(find.text('Color Alchemist'), findsNothing);
    });

    testWidgets('every row of a full 24-game history fits', (tester) async {
      _phone(tester);
      await tester.pumpWidget(_app(_populated(), const HistoryScreen()));
      await tester.pump();
      await _scrollToEnd(tester);
      expect(tester.takeException(), isNull);
      expect(find.textContaining('correct'), findsWidgets);
    });

    testWidgets('survives 150% text scale', (tester) async {
      _phone(tester);
      await tester.pumpWidget(
        _app(_populated(), const HistoryScreen(), textScale: 1.5),
      );
      await tester.pump();
      await _scrollToEnd(tester);
      expect(tester.takeException(), isNull);
    });

    testWidgets('empty profile shows the empty state, no overflow', (
      tester,
    ) async {
      _phone(tester);
      await tester.pumpWidget(_app(const PlayerStats(), const HistoryScreen()));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('Nothing to chart yet'), findsOneWidget);
      expect(find.text('PLAY A GAME'), findsOneWidget);
    });

    testWidgets('empty state survives 150% text scale', (tester) async {
      _phone(tester);
      await tester.pumpWidget(
        _app(const PlayerStats(), const HistoryScreen(), textScale: 1.5),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('upgraded install still gets a chart before any dated rows', (
      tester,
    ) async {
      _phone(tester);
      await tester.pumpWidget(_app(_upgraded(), const HistoryScreen()));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.textContaining('already in the chart'), findsOneWidget);
      expect(find.text('last 5 games'), findsOneWidget);
      // 5 scores is enough for a trend.
      expect(find.textContaining('vs your previous'), findsOneWidget);
    });

    testWidgets('a brand-new player with one game sees a nudge, not a trend', (
      tester,
    ) async {
      _phone(tester);
      final one = PlayerStats(
        bestByMode: const {'shade': 450},
        recentScoresByMode: const {
          'shade': [450],
        },
        history: [_rec('shade', 0)],
      );
      await tester.pumpWidget(_app(one, const HistoryScreen()));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.textContaining('Play 3 more games'), findsOneWidget);
      expect(find.textContaining('Play one more game'), findsOneWidget);
    });

    testWidgets('tapping a chip switches the mode shown', (tester) async {
      _phone(tester);
      await tester.pumpWidget(_app(_populated(), const HistoryScreen()));
      await tester.pump();
      // Default is the most recently played mode (shade), 24 games.
      expect(find.text('last 24 games'), findsOneWidget);

      await tester.tap(find.text('Odd Chroma'));
      await tester.pump();
      expect(find.text('last 6 games'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the "last N games" label is right-aligned in the chart card', (
      tester,
    ) async {
      _phone(tester);
      await tester.pumpWidget(_app(_populated(), const HistoryScreen()));
      await tester.pump();
      final card = tester.getTopRight(find.byType(SectionCard).first);
      final label = tester.getTopRight(find.text('last 24 games'));
      // Card padding is 16 on a phone; allow a pixel of border.
      expect(card.dx - label.dx, inInclusiveRange(15, 18));
    });

    testWidgets('switching modes starts the new one at the top', (
      tester,
    ) async {
      _phone(tester);
      await tester.pumpWidget(_app(_populated(), const HistoryScreen()));
      await tester.pump();
      final body = find.byType(Scrollable).last;
      await tester.drag(body, const Offset(0, -400));
      await tester.pump();
      expect(
        tester.state<ScrollableState>(body).position.pixels,
        greaterThan(0),
      );

      await tester.tap(find.text('Odd Chroma'));
      await tester.pump();
      expect(
        tester
            .state<ScrollableState>(find.byType(Scrollable).last)
            .position
            .pixels,
        0,
      );
    });

    testWidgets('opens on the mode focused from the Stats screen', (
      tester,
    ) async {
      _phone(tester);
      await tester.pumpWidget(
        _app(_populated(), const HistoryScreen(), focus: 'odd'),
      );
      await tester.pump();
      expect(find.text('last 6 games'), findsOneWidget);
    });

    testWidgets('stars only the personal-best game', (tester) async {
      _phone(tester);
      GameRecord game(int score, int hoursAgo) => GameRecord(
        modeId: 'shade',
        score: score,
        correct: 8,
        rounds: 10,
        avgTimeMs: 2000,
        playedAtMs: _now
            .subtract(Duration(hours: hoursAgo))
            .millisecondsSinceEpoch,
      );
      final stats = PlayerStats(
        bestByMode: const {'shade': 900},
        recentScoresByMode: const {
          'shade': [500, 900, 400],
        },
        history: [game(500, 1), game(900, 2), game(400, 3)],
      );
      await tester.pumpWidget(_app(stats, const HistoryScreen()));
      await tester.pump();
      // The rows sit below the chart and summary cards.
      await tester.scrollUntilVisible(
        find.byIcon(Icons.star_rounded),
        100,
        scrollable: find.byType(Scrollable).last,
      );
      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    });
  });

  group('ScoreChartPainter', () {
    Future<void> paint(
      WidgetTester tester,
      List<int> values, {
      double? avg,
    }) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 240,
            height: 120,
            child: CustomPaint(
              painter: ScoreChartPainter(
                values: values,
                color: Colors.green,
                average: avg,
              ),
              size: Size.infinite,
            ),
          ),
        ),
      );
    }

    testWidgets('paints empty, single, flat and long series without errors', (
      tester,
    ) async {
      await paint(tester, const []);
      await paint(tester, const [500]);
      await paint(tester, const [500, 500, 500], avg: 500);
      await paint(tester, [
        for (var i = 0; i < 30; i++) 100 + i * 17 % 90,
      ], avg: 140);
      expect(tester.takeException(), isNull);
    });

    test('repaints only when the data changes', () {
      const a = ScoreChartPainter(values: [1, 2, 3], color: Colors.green);
      expect(
        a.shouldRepaint(
          const ScoreChartPainter(values: [1, 2, 3], color: Colors.green),
        ),
        isFalse,
      );
      expect(
        a.shouldRepaint(
          const ScoreChartPainter(values: [1, 2, 4], color: Colors.green),
        ),
        isTrue,
      );
    });
  });

  group('StatsScreen entry points', () {
    testWidgets('lays out at 360x640 with the new Progress card', (
      tester,
    ) async {
      _phone(tester);
      await tester.pumpWidget(_app(_populated(), const StatsScreen()));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('Progress & history'), findsOneWidget);
    });

    testWidgets('Progress card opens the history screen', (tester) async {
      _phone(tester);
      final container = ProviderContainer(
        overrides: [
          playerProvider.overrideWith(() => _FakePlayer(_populated())),
          audioServiceProvider.overrideWithValue(_SilentAudio()),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: const StatsScreen(),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Progress & history'));
      await tester.pump();
      expect(container.read(screenProvider), AppScreen.history);
      expect(container.read(historyFocusProvider), isNull);
    });

    testWidgets('tapping a mode card focuses that mode', (tester) async {
      _phone(tester);
      final container = ProviderContainer(
        overrides: [
          playerProvider.overrideWith(() => _FakePlayer(_populated())),
          audioServiceProvider.overrideWithValue(_SilentAudio()),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: const StatsScreen(),
          ),
        ),
      );
      await tester.pump();

      await tester.ensureVisible(find.text('Odd Chroma'));
      await tester.tap(find.text('Odd Chroma'));
      await tester.pump();
      expect(container.read(screenProvider), AppScreen.history);
      expect(container.read(historyFocusProvider), 'odd');
    });

    testWidgets('a mode with no games is not tappable', (tester) async {
      _phone(tester);
      final container = ProviderContainer(
        overrides: [
          playerProvider.overrideWith(() => _FakePlayer(_populated())),
          audioServiceProvider.overrideWithValue(_SilentAudio()),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: const StatsScreen(),
          ),
        ),
      );
      await tester.pump();

      await tester.ensureVisible(find.text('Color Alchemist'));
      await tester.tap(find.text('Color Alchemist'));
      await tester.pump();
      expect(container.read(screenProvider), AppScreen.menu);
    });
  });
}
