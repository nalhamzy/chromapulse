import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chromapulse/core/constants/app_colors.dart';
import 'package:chromapulse/core/models/game_mode.dart';
import 'package:chromapulse/core/services/audio_service.dart';
import 'package:chromapulse/core/utils/responsive.dart';
import 'package:chromapulse/providers/audio_provider.dart';
import 'package:chromapulse/providers/game_provider.dart';
import 'package:chromapulse/providers/navigation_provider.dart';
import 'package:chromapulse/providers/player_provider.dart';
import 'package:chromapulse/widgets/common/pulse_logo.dart';
import 'package:chromapulse/widgets/game/daily_challenge_banner.dart';
import 'package:chromapulse/widgets/game/mode_card.dart';
import 'package:chromapulse/widgets/game/stats_bar.dart';

class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: ResponsiveContentBox(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              context.s(20),
              context.s(24),
              context.s(20),
              context.s(24),
            ),
            child: Column(
              children: [
                const PulseLogo(),
                SizedBox(height: context.s(20)),
                const DailyChallengeBanner(),
                SizedBox(height: context.s(12)),
                InkWell(
                  borderRadius: BorderRadius.circular(context.s(16)),
                  onTap: () {
                    ref.read(audioServiceProvider).play(SoundEffect.buttonTap);
                    ref.read(screenProvider.notifier).go(AppScreen.stats);
                  },
                  child: const StatsBar(),
                ),
                SizedBox(height: context.s(16)),
                for (final m in GameMode.values) ...[
                  ModeCard(
                    mode: m,
                    bestScore: player.bestFor(m.id),
                    locked: m.vipOnly && !player.vip,
                    onTap: () => _onModeTap(ref, m, player.vip),
                  ),
                  SizedBox(height: context.s(12)),
                ],
                SizedBox(height: context.s(8)),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: context.s(6),
                  runSpacing: context.s(2),
                  children: [
                    _MenuLink(
                      icon: Icons.shopping_bag_outlined,
                      label: 'SHOP',
                      onTap: () {
                        ref
                            .read(audioServiceProvider)
                            .play(SoundEffect.buttonTap);
                        ref.read(screenProvider.notifier).go(AppScreen.shop);
                      },
                    ),
                    _MenuLink(
                      icon: Icons.emoji_events_outlined,
                      label: 'AWARDS',
                      onTap: () {
                        ref
                            .read(audioServiceProvider)
                            .play(SoundEffect.buttonTap);
                        ref
                            .read(screenProvider.notifier)
                            .go(AppScreen.achievements);
                      },
                    ),
                    _MenuLink(
                      icon: Icons.settings_outlined,
                      label: 'SETTINGS',
                      onTap: () {
                        ref
                            .read(audioServiceProvider)
                            .play(SoundEffect.buttonTap);
                        ref.read(screenProvider.notifier).go(AppScreen.settings);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onModeTap(WidgetRef ref, GameMode mode, bool vip) {
    ref.read(audioServiceProvider).play(SoundEffect.buttonTap);
    if (mode.vipOnly && !vip) {
      ref.read(screenProvider.notifier).go(AppScreen.shop);
      return;
    }
    ref.read(gameProvider.notifier).startGame(mode);
    ref.read(screenProvider.notifier).go(AppScreen.game);
  }
}

class _MenuLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      style: TextButton.styleFrom(
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsets.symmetric(
          horizontal: context.s(6),
          vertical: context.s(8),
        ),
      ),
      icon: Icon(icon, color: AppColors.textDim, size: context.s(18)),
      label: Text(
        label,
        style: TextStyle(
          color: AppColors.textDim,
          fontWeight: FontWeight.w600,
          letterSpacing: 2,
          fontSize: context.s(11),
        ),
      ),
    );
  }
}
