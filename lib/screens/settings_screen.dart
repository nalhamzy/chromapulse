import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:chromapulse/core/constants/app_colors.dart';
import 'package:chromapulse/core/services/audio_service.dart';
import 'package:chromapulse/core/utils/responsive.dart';
import 'package:chromapulse/providers/audio_provider.dart';
import 'package:chromapulse/providers/iap_provider.dart';
import 'package:chromapulse/providers/navigation_provider.dart';
import 'package:chromapulse/providers/player_provider.dart';
import 'package:chromapulse/widgets/common/section_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _appVersion = '1.1.0';
  static const _privacyUrl =
      'https://nalhamzy.github.io/chromapulse/privacy.html';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(playerProvider);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: ResponsiveContentBox(
          child: Column(
            children: [
              _Header(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    context.s(16),
                    context.s(8),
                    context.s(16),
                    context.s(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SectionTitle('Audio & feedback'),
                      SizedBox(height: context.s(8)),
                      _ToggleRow(
                        icon: Icons.volume_up_rounded,
                        label: 'Sound effects',
                        value: p.soundEnabled,
                        onChanged: (_) {
                          ref
                              .read(audioServiceProvider)
                              .play(SoundEffect.buttonTap);
                          ref.read(playerProvider.notifier).toggleSound();
                        },
                      ),
                      SizedBox(height: context.s(10)),
                      _ToggleRow(
                        icon: Icons.vibration_rounded,
                        label: 'Haptics',
                        value: p.hapticsEnabled,
                        onChanged: (_) {
                          ref
                              .read(audioServiceProvider)
                              .play(SoundEffect.buttonTap);
                          ref.read(playerProvider.notifier).toggleHaptics();
                        },
                      ),
                      SizedBox(height: context.s(20)),
                      _SectionTitle('Account'),
                      SizedBox(height: context.s(8)),
                      _ActionRow(
                        icon: Icons.restore_rounded,
                        label: 'Restore purchases',
                        onTap: () async {
                          ref
                              .read(audioServiceProvider)
                              .play(SoundEffect.buttonTap);
                          await ref
                              .read(iapServiceProvider)
                              .restorePurchases();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Restore requested'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      ),
                      SizedBox(height: context.s(20)),
                      _SectionTitle('Data'),
                      SizedBox(height: context.s(8)),
                      _ActionRow(
                        icon: Icons.delete_outline_rounded,
                        label: 'Reset stats',
                        destructive: true,
                        onTap: () => _confirmReset(context, ref),
                      ),
                      SizedBox(height: context.s(20)),
                      _SectionTitle('About'),
                      SizedBox(height: context.s(8)),
                      _ActionRow(
                        icon: Icons.privacy_tip_outlined,
                        label: 'Privacy policy',
                        onTap: () async {
                          ref
                              .read(audioServiceProvider)
                              .play(SoundEffect.buttonTap);
                          final uri = Uri.parse(_privacyUrl);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          }
                        },
                      ),
                      SizedBox(height: context.s(10)),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: context.s(20)),
                          child: Text(
                            'ChromaPulse v$_appVersion',
                            style: TextStyle(
                              color: AppColors.textDim,
                              fontSize: context.s(12),
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Reset stats?'),
        content: const Text(
          'This wipes your scores, history, streak, and achievements. Purchases stay intact. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'RESET',
              style: TextStyle(color: AppColors.accent2),
            ),
          ),
        ],
      ),
    );
    if (ok == true) {
      ref.read(playerProvider.notifier).resetStats();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stats reset'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}

class _Header extends ConsumerWidget {
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
            onPressed: () {
              ref.read(audioServiceProvider).play(SoundEffect.buttonTap);
              ref.read(screenProvider.notifier).go(AppScreen.menu);
            },
            icon: const Icon(Icons.arrow_back, color: AppColors.textDim),
          ),
          Expanded(
            child: Text(
              'SETTINGS',
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
          fontSize: context.s(11),
          letterSpacing: 2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Row(
        children: [
          Icon(icon, color: AppColors.textDim, size: context.s(20)),
          SizedBox(width: context.s(12)),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.text,
                fontSize: context.s(14),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            activeThumbColor: AppColors.accent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.accent2 : AppColors.text;
    return InkWell(
      borderRadius: BorderRadius.circular(context.s(16)),
      onTap: onTap,
      child: SectionCard(
        child: Row(
          children: [
            Icon(icon, color: color, size: context.s(20)),
            SizedBox(width: context.s(12)),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: context.s(14),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textDim),
          ],
        ),
      ),
    );
  }
}
