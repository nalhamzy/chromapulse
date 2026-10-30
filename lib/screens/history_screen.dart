import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chromapulse/core/constants/app_colors.dart';
import 'package:chromapulse/core/constants/theme.dart';
import 'package:chromapulse/core/models/game_mode.dart';
import 'package:chromapulse/core/models/game_record.dart';
import 'package:chromapulse/core/models/mode_progress.dart';
import 'package:chromapulse/core/services/audio_service.dart';
import 'package:chromapulse/core/utils/responsive.dart';
import 'package:chromapulse/providers/audio_provider.dart';
import 'package:chromapulse/providers/history_provider.dart';
import 'package:chromapulse/providers/navigation_provider.dart';
import 'package:chromapulse/providers/player_provider.dart';
import 'package:chromapulse/widgets/common/gradient_button.dart';
import 'package:chromapulse/widgets/common/section_card.dart';
import 'package:chromapulse/widgets/game/result_stat_block.dart';

/// Progress & history: a score chart, trend and dated game list per mode.
/// Works entirely from on-device data (no network, no permissions).
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = ref.read(historyFocusProvider);
  }

  @override
  Widget build(BuildContext context) {
    final p = ref.watch(playerProvider);
    final played = ModeProgress.playedModes(p);

    var mode = GameMode.byId(_selectedId ?? '');
    if (mode == null || !played.contains(mode)) {
      mode = ModeProgress.defaultMode(p);
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: ResponsiveContentBox(
          child: Column(
            children: [
              const _Header(),
              if (mode == null)
                const Expanded(child: _EmptyState())
              else ...[
                _ModeChips(
                  modes: played,
                  selected: mode,
                  onSelect: (m) => setState(() => _selectedId = m.id),
                ),
                Expanded(
                  child: _ProgressBody(
                    // New key per mode so each one opens scrolled to the top.
                    key: ValueKey(mode.id),
                    progress: ModeProgress.of(p, mode),
                    now: DateTime.now(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.s(8),
        context.s(8),
        context.s(16),
        context.s(8),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Back to stats',
            onPressed: () {
              ref.read(audioServiceProvider).play(SoundEffect.buttonTap);
              ref.read(screenProvider.notifier).go(AppScreen.stats);
            },
            icon: const Icon(Icons.arrow_back, color: AppColors.textDim),
          ),
          Expanded(
            child: Text(
              'PROGRESS',
              style: TextStyle(
                color: AppColors.text,
                fontSize: context.s(18),
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends ConsumerWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.s(32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.show_chart_rounded,
              color: AppColors.textDim,
              size: context.s(48),
            ),
            SizedBox(height: context.s(16)),
            Text(
              'Nothing to chart yet',
              style: TextStyle(
                color: AppColors.text,
                fontSize: context.s(18),
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: context.s(8)),
            Text(
              'Finish a game and your scores, accuracy and trend will build up here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textDim,
                fontSize: context.s(13),
                height: 1.5,
              ),
            ),
            SizedBox(height: context.s(24)),
            GradientButton(
              text: 'PLAY A GAME',
              fullWidth: true,
              gradient: AppTheme.logoGradient1,
              textColor: Colors.black,
              icon: Icons.play_arrow_rounded,
              onPressed: () {
                ref.read(audioServiceProvider).play(SoundEffect.buttonTap);
                ref.read(screenProvider.notifier).go(AppScreen.menu);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeChips extends ConsumerWidget {
  final List<GameMode> modes;
  final GameMode selected;
  final ValueChanged<GameMode> onSelect;

  const _ModeChips({
    required this.modes,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: context.s(48),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: context.s(16)),
        itemCount: modes.length,
        separatorBuilder: (_, _) => SizedBox(width: context.s(8)),
        itemBuilder: (context, i) {
          final m = modes[i];
          final isSel = m == selected;
          return Semantics(
            button: true,
            selected: isSel,
            label: m.label,
            child: InkWell(
              borderRadius: BorderRadius.circular(context.s(12)),
              onTap: () {
                if (isSel) return;
                ref.read(audioServiceProvider).play(SoundEffect.buttonTap);
                onSelect(m);
              },
              child: Container(
                constraints: BoxConstraints(minHeight: context.s(44)),
                padding: EdgeInsets.symmetric(horizontal: context.s(14)),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSel
                      ? m.accent.withValues(alpha: 0.14)
                      : AppColors.surface2,
                  borderRadius: BorderRadius.circular(context.s(12)),
                  border: Border.all(
                    color: isSel
                        ? m.accent.withValues(alpha: 0.7)
                        : Colors.white.withValues(alpha: 0.06),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      m.iconGlyph,
                      style: TextStyle(
                        color: m.accent,
                        fontSize: context.s(16),
                      ),
                    ),
                    SizedBox(width: context.s(6)),
                    Text(
                      m.label,
                      style: TextStyle(
                        color: isSel ? AppColors.text : AppColors.textDim,
                        fontSize: context.s(13),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProgressBody extends ConsumerWidget {
  final ModeProgress progress;
  final DateTime now;

  const _ProgressBody({super.key, required this.progress, required this.now});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        context.s(16),
        context.s(12),
        context.s(16),
        context.s(24),
      ),
      children: [
        _ChartCard(progress: progress),
        SizedBox(height: context.s(12)),
        _SummaryCard(progress: progress),
        SizedBox(height: context.s(20)),
        _SectionTitle('Recent games'),
        SizedBox(height: context.s(8)),
        if (progress.records.isEmpty)
          SectionCard(
            child: Text(
              'Dates and accuracy for each game show up here as you play. '
              'Your last ${progress.scores.length} '
              'score${progress.scores.length == 1 ? '' : 's'} '
              '${progress.scores.length == 1 ? 'is' : 'are'} already in the chart.',
              style: TextStyle(
                color: AppColors.textDim,
                fontSize: context.s(12),
                height: 1.5,
              ),
            ),
          )
        else
          for (final r in progress.records) ...[
            _GameRow(record: r, best: progress.best, now: now),
            SizedBox(height: context.s(8)),
          ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: context.s(4)),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: AppColors.textDim,
          fontSize: context.s(12),
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final ModeProgress progress;
  const _ChartCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    final values = progress.chartScores;
    final hi = values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b);
    final lo = values.isEmpty ? 0 : values.reduce((a, b) => a < b ? a : b);
    final n = values.length;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'SCORES',
                style: TextStyle(
                  color: AppColors.textDim,
                  fontSize: context.s(11),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(width: context.s(8)),
              Expanded(
                child: Text(
                  n == 0 ? '' : 'last $n game${n == 1 ? '' : 's'}',
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textDim,
                    fontSize: context.s(11),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.s(12)),
          SizedBox(
            height: context.s(130),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: context.s(44),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _AxisLabel('$hi'),
                      if (hi != lo) _AxisLabel('$lo'),
                    ],
                  ),
                ),
                SizedBox(width: context.s(8)),
                Expanded(
                  child: Semantics(
                    label: n < 2
                        ? 'Score chart, one game so far'
                        : 'Score chart over the last $n games, '
                              'from $lo to $hi points',
                    child: CustomPaint(
                      painter: ScoreChartPainter(
                        values: values,
                        color: progress.mode.accent,
                        average: progress.recentAverage,
                      ),
                      size: Size.infinite,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (n >= 2) ...[
            SizedBox(height: context.s(10)),
            Row(
              children: [
                _LegendDash(color: Colors.white.withValues(alpha: 0.45)),
                SizedBox(width: context.s(6)),
                Expanded(
                  child: Text(
                    'Average of your latest ${n < ModeProgress.recentWindow ? n : ModeProgress.recentWindow}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textDim,
                      fontSize: context.s(11),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            SizedBox(height: context.s(10)),
            Text(
              'Play one more game to draw your line.',
              style: TextStyle(
                color: AppColors.textDim,
                fontSize: context.s(11),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AxisLabel extends StatelessWidget {
  final String text;
  const _AxisLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.visible,
      style: AppTheme.mono(
        fontSize: context.s(11),
        color: AppColors.textDim,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _LegendDash extends StatelessWidget {
  final Color color;
  const _LegendDash({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.s(18),
      height: 2,
      child: CustomPaint(painter: _DashPainter(color)),
    );
  }
}

class _DashPainter extends CustomPainter {
  final Color color;
  _DashPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _dashedHLine(canvas, 0, size.width, size.height / 2, color);
  }

  @override
  bool shouldRepaint(covariant _DashPainter old) => old.color != color;
}

void _dashedHLine(Canvas canvas, double x0, double x1, double y, Color color) {
  final paint = Paint()
    ..color = color
    ..strokeWidth = 1.5
    ..style = PaintingStyle.stroke;
  const dash = 5.0;
  const gap = 4.0;
  var x = x0;
  while (x < x1) {
    final end = x + dash > x1 ? x1 : x + dash;
    canvas.drawLine(Offset(x, y), Offset(end, y), paint);
    x += dash + gap;
  }
}

/// Line chart of scores (oldest to newest) with a soft fill and a dashed
/// average line. Public so tests can paint it directly.
class ScoreChartPainter extends CustomPainter {
  final List<int> values;
  final Color color;
  final double? average;

  const ScoreChartPainter({
    required this.values,
    required this.color,
    this.average,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty || size.width <= 0 || size.height <= 0) return;

    const inset = 6.0;
    final top = inset;
    final bottom = size.height - inset;
    final h = bottom - top;

    var lo = values.reduce((a, b) => a < b ? a : b).toDouble();
    var hi = values.reduce((a, b) => a > b ? a : b).toDouble();
    if (hi - lo < 1) {
      // Flat series: centre it instead of dividing by zero.
      lo -= 1;
      hi += 1;
    }
    double yFor(double v) => bottom - ((v - lo) / (hi - lo)) * h;

    // Faint guide lines at the top, middle and bottom of the range.
    final grid = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    for (final y in [top, (top + bottom) / 2, bottom]) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final n = values.length;
    final dx = n == 1 ? 0.0 : (size.width - inset * 2) / (n - 1);
    Offset pt(int i) => Offset(
      n == 1 ? size.width / 2 : inset + i * dx,
      yFor(values[i].toDouble()),
    );

    if (average != null && n >= 2) {
      _dashedHLine(
        canvas,
        0,
        size.width,
        yFor(average!.clamp(lo, hi)),
        Colors.white.withValues(alpha: 0.45),
      );
    }

    if (n >= 2) {
      final line = Path()..moveTo(pt(0).dx, pt(0).dy);
      for (var i = 1; i < n; i++) {
        line.lineTo(pt(i).dx, pt(i).dy);
      }
      final fill = Path.from(line)
        ..lineTo(pt(n - 1).dx, bottom)
        ..lineTo(pt(0).dx, bottom)
        ..close();
      canvas.drawPath(
        fill,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: 0.28),
              color.withValues(alpha: 0.0),
            ],
          ).createShader(Rect.fromLTWH(0, top, size.width, h)),
      );
      canvas.drawPath(
        line,
        Paint()
          ..color = color
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    // Dots: every point on short series, then just the newest.
    final dotPaint = Paint()..color = color;
    if (n <= 12) {
      for (var i = 0; i < n - 1; i++) {
        canvas.drawCircle(pt(i), 2.5, dotPaint);
      }
    }
    canvas.drawCircle(pt(n - 1), 4.5, Paint()..color = AppColors.gold);
  }

  @override
  bool shouldRepaint(covariant ScoreChartPainter old) =>
      old.color != color ||
      old.average != average ||
      !_sameValues(old.values, values);

  static bool _sameValues(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class _SummaryCard extends StatelessWidget {
  final ModeProgress progress;
  const _SummaryCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    final avg = progress.recentAverage;
    final acc = progress.recentAccuracyPct;
    return SectionCard(
      padding: EdgeInsets.symmetric(
        horizontal: context.s(16),
        vertical: context.s(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _StatCell(
                value: '${progress.best}',
                label: 'Best',
                color: AppColors.gold,
              ),
              _StatCell(
                value: avg == null ? '—' : '${avg.round()}',
                label: 'Average',
                color: AppColors.accent,
              ),
              _StatCell(
                value: acc == null ? '—' : '$acc%',
                label: 'Accuracy',
                color: AppColors.accent3,
              ),
            ],
          ),
          SizedBox(height: context.s(14)),
          _TrendPill(progress: progress),
          SizedBox(height: context.s(10)),
          Text(
            'Average and accuracy cover your latest ${ModeProgress.recentWindow} games.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textDim, fontSize: context.s(11)),
          ),
        ],
      ),
    );
  }
}

/// One equal-width stat that shrinks to fit rather than overflowing when the
/// player runs large system text.
class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatCell({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: ResultStatBlock(value: value, label: label, valueColor: color),
      ),
    );
  }
}

class _TrendPill extends StatelessWidget {
  final ModeProgress progress;
  const _TrendPill({required this.progress});

  @override
  Widget build(BuildContext context) {
    final t = progress.trend;
    final IconData icon;
    final Color color;
    final String text;
    if (t == null) {
      final need = ModeProgress.minGamesForTrend - progress.scores.length;
      icon = Icons.trending_flat_rounded;
      color = AppColors.textDim;
      text = need > 0
          ? 'Play $need more game${need == 1 ? '' : 's'} to see your trend'
          : 'Not enough score history for a trend yet';
    } else {
      switch (t.direction) {
        case TrendDirection.up:
          icon = Icons.trending_up_rounded;
          color = AppColors.accent;
          text = 'Up ${t.pct}% vs your previous ${t.window} games';
        case TrendDirection.down:
          icon = Icons.trending_down_rounded;
          color = AppColors.accent2;
          text = 'Down ${t.pct}% vs your previous ${t.window} games';
        case TrendDirection.steady:
          icon = Icons.trending_flat_rounded;
          color = AppColors.textDim;
          text = 'Holding steady vs your previous ${t.window} games';
      }
    }
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.s(14),
        vertical: context.s(10),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(context.s(12)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: context.s(20)),
          SizedBox(width: context.s(8)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color == AppColors.textDim ? AppColors.text : color,
                fontSize: context.s(13),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GameRow extends StatelessWidget {
  final GameRecord record;
  final int best;
  final DateTime now;

  const _GameRow({required this.record, required this.best, required this.now});

  @override
  Widget build(BuildContext context) {
    final when = record.playedAt;
    final isBest = best > 0 && record.score >= best;
    return SectionCard(
      padding: EdgeInsets.symmetric(
        horizontal: context.s(14),
        vertical: context.s(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: dayLabel(when, now),
                              style: TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.w700,
                                fontSize: context.s(14),
                              ),
                            ),
                            TextSpan(
                              text:
                                  '  \u00b7  ${TimeOfDay.fromDateTime(when).format(context)}',
                              style: TextStyle(
                                color: AppColors.textDim,
                                fontSize: context.s(12),
                              ),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (record.daily) ...[
                      SizedBox(width: context.s(6)),
                      Icon(
                        Icons.local_fire_department_rounded,
                        color: AppColors.accent2,
                        size: context.s(15),
                        semanticLabel: 'Daily challenge',
                      ),
                    ],
                  ],
                ),
                SizedBox(height: context.s(3)),
                Text(
                  '${record.correct}/${record.rounds} correct'
                  '  \u00b7  ${record.avgTimeSec.toStringAsFixed(1)}s avg',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textDim,
                    fontSize: context.s(12),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: context.s(10)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isBest) ...[
                Icon(
                  Icons.star_rounded,
                  color: AppColors.gold,
                  size: context.s(16),
                  semanticLabel: 'Personal best',
                ),
                SizedBox(width: context.s(2)),
              ],
              Text(
                '${record.score}',
                style: AppTheme.mono(
                  fontSize: context.s(16),
                  color: isBest ? AppColors.gold : AppColors.text,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
