import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chromapulse/core/constants/app_colors.dart';
import 'package:chromapulse/core/constants/theme.dart';
import 'package:chromapulse/core/services/audio_service.dart';
import 'package:chromapulse/core/services/iap_service.dart';
import 'package:chromapulse/core/utils/responsive.dart';
import 'package:chromapulse/providers/audio_provider.dart';
import 'package:chromapulse/providers/iap_provider.dart';
import 'package:chromapulse/providers/navigation_provider.dart';
import 'package:chromapulse/providers/player_provider.dart';
import 'package:chromapulse/widgets/common/gradient_button.dart';
import 'package:chromapulse/widgets/common/section_card.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: ResponsiveContentBox(
          child: Column(
            children: [
              _Header(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(context.s(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SectionTitle('✨ Upgrades'),
                      SizedBox(height: context.s(8)),
                      _IapTile(
                        icon: '🚫',
                        name: 'Remove Ads',
                        description:
                            'Hide all banner and interstitial ads forever.',
                        productId: IapProductIds.removeAds,
                        owned: player.adsRemoved,
                        fallbackPrice: '\$1.99',
                        accentColor: AppColors.accent3,
                      ),
                      SizedBox(height: context.s(12)),
                      _IapTile(
                        icon: '👑',
                        name: 'VIP Pass',
                        description:
                            'Removes ads and unlocks the Palette Match game mode.',
                        productId: IapProductIds.vipPass,
                        owned: player.vip,
                        fallbackPrice: '\$4.99',
                        accentColor: AppColors.gold,
                      ),
                      SizedBox(height: context.s(24)),
                      Center(
                        child: TextButton(
                          onPressed: () async {
                            final iap = ref.read(iapServiceProvider);
                            await iap.restorePurchases();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Restore requested'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          child: Text(
                            'RESTORE PURCHASES',
                            style: TextStyle(
                              color: AppColors.textDim,
                              letterSpacing: 2,
                              fontSize: context.s(12),
                              fontWeight: FontWeight.w600,
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
}

class _Header extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.fromLTRB(context.s(8), context.s(8), context.s(16), context.s(8)),
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
              'SHOP',
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
      padding: EdgeInsets.only(left: context.s(4), bottom: context.s(4)),
      child: Text(
        text,
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

class _IapTile extends ConsumerWidget {
  final String icon;
  final String name;
  final String description;
  final String productId;
  final bool owned;
  final String fallbackPrice;
  final Color accentColor;

  const _IapTile({
    required this.icon,
    required this.name,
    required this.description,
    required this.productId,
    required this.owned,
    required this.fallbackPrice,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SectionCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(icon, style: TextStyle(fontSize: context.s(28))),
          SizedBox(width: context.s(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: context.s(16),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: context.s(4)),
                Text(
                  description,
                  style: TextStyle(
                    color: AppColors.textDim,
                    fontSize: context.s(12),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: context.s(12)),
          owned
              ? Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: context.s(12), vertical: context.s(6)),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(context.s(10)),
                  ),
                  child: Text(
                    'OWNED',
                    style: AppTheme.mono(
                      fontSize: context.s(11),
                      color: AppColors.accent,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                )
              : _BuyButton(
                  productId: productId,
                  fallbackPrice: fallbackPrice,
                  accentColor: accentColor,
                ),
        ],
      ),
    );
  }
}

class _BuyButton extends ConsumerWidget {
  final String productId;
  final String fallbackPrice;
  final Color accentColor;

  const _BuyButton({
    required this.productId,
    required this.fallbackPrice,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iap = ref.watch(iapServiceProvider);
    final info = iap.productInfo(productId);
    final price = info?.formattedPrice ?? fallbackPrice;
    return GradientButton(
      text: price,
      width: 100,
      gradient: LinearGradient(
        colors: [accentColor, accentColor.withValues(alpha: 0.7)],
      ),
      textColor: Colors.white,
      onPressed: () async {
        ref.read(audioServiceProvider).play(SoundEffect.buttonTap);
        final iap = ref.read(iapServiceProvider);
        await iap.ensureInitialized();
        final ok = await iap.purchase(productId);
        if (!ok && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Store not available. Try again later.'),
            ),
          );
        }
      },
    );
  }
}
