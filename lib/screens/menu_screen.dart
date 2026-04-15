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
                const StatsBar(),
                SizedBox(height: context.s(16)),
                for (final m in GameMode.values) ...[
                  ModeCard(
                    mode: m,
                    bestScore: player.bestFor(m.id),
                    onTap: () => _startMode(ref, m),
                  ),
                  SizedBox(height: context.s(12)),
                ],
                SizedBox(height: context.s(8)),
                TextButton.icon(
                  onPressed: () {
                    ref.read(audioServiceProvider).play(SoundEffect.buttonTap);
                    ref.read(screenProvider.notifier).go(AppScreen.shop);
                  },
                  icon: const Icon(Icons.shopping_bag_outlined,
                      color: AppColors.textDim),
                  label: Text(
                    'SHOP',
                    style: TextStyle(
                      color: AppColors.textDim,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                      fontSize: context.s(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _startMode(WidgetRef ref, GameMode mode) {
    ref.read(audioServiceProvider).play(SoundEffect.buttonTap);
    ref.read(gameProvider.notifier).startGame(mode);
    ref.read(screenProvider.notifier).go(AppScreen.game);
  }
}
