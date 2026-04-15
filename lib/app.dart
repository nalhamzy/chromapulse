import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chromapulse/core/constants/app_colors.dart';
import 'package:chromapulse/core/constants/theme.dart';
import 'package:chromapulse/core/models/game_state.dart';
import 'package:chromapulse/core/services/iap_service.dart';
import 'package:chromapulse/providers/ad_provider.dart';
import 'package:chromapulse/providers/game_provider.dart';
import 'package:chromapulse/providers/iap_provider.dart';
import 'package:chromapulse/providers/navigation_provider.dart';
import 'package:chromapulse/providers/player_provider.dart';
import 'package:chromapulse/screens/game_screen.dart';
import 'package:chromapulse/screens/menu_screen.dart';
import 'package:chromapulse/screens/result_screen.dart';
import 'package:chromapulse/screens/shop_screen.dart';
import 'package:chromapulse/widgets/common/ad_banner_widget.dart';

class ChromaPulseApp extends StatelessWidget {
  const ChromaPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChromaPulse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const _AppShell(),
    );
  }
}

class _AppShell extends ConsumerStatefulWidget {
  const _AppShell();

  @override
  ConsumerState<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<_AppShell> {
  @override
  void initState() {
    super.initState();
    // Wire IAP purchase callbacks to player state.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final iap = ref.read(iapServiceProvider);
      final playerNotifier = ref.read(playerProvider.notifier);
      iap.onPurchaseSuccess = (productId) {
        switch (productId) {
          case IapProductIds.removeAds:
            playerNotifier.activateRemoveAds();
          case IapProductIds.vipPass:
            playerNotifier.activateVip();
        }
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen for game end → optional interstitial → navigate to result.
    ref.listen(gameProvider.select((g) => g.phase), (prev, next) {
      if (prev == GamePhase.playing && next == GamePhase.finished) {
        final ads = ref.read(adServiceProvider);
        final player = ref.read(playerProvider);
        if (player.adsRemoved) {
          ref.read(screenProvider.notifier).go(AppScreen.result);
        } else {
          ads.maybeShowInterstitial(onDismissed: () {
            ref.read(screenProvider.notifier).go(AppScreen.result);
          });
        }
      }
    });

    final current = ref.watch(screenProvider);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.03),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
            child: child,
          ),
        ),
        child: KeyedSubtree(
          key: ValueKey(current),
          child: _screenFor(current),
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }

  Widget _screenFor(AppScreen s) {
    switch (s) {
      case AppScreen.menu:
        return const MenuScreen();
      case AppScreen.game:
        return const GameScreen();
      case AppScreen.result:
        return const ResultScreen();
      case AppScreen.shop:
        return const ShopScreen();
    }
  }
}
