import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chromapulse/providers/ad_provider.dart';
import 'package:chromapulse/providers/navigation_provider.dart';
import 'package:chromapulse/providers/player_provider.dart';

/// Bottom banner slot. Rendered on every screen except [AppScreen.game].
/// Hidden entirely when the player has purchased Remove Ads or VIP.
class AdBannerWidget extends ConsumerWidget {
  const AdBannerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adsRemoved = ref.watch(playerProvider.select((p) => p.adsRemoved));
    final screen = ref.watch(screenProvider);
    if (adsRemoved || screen == AppScreen.game) {
      return const SizedBox.shrink();
    }
    final banner = ref.watch(adServiceProvider).buildBanner();
    if (banner == null) return const SizedBox.shrink();
    return banner;
  }
}
