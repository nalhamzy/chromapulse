import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:chromapulse/core/services/iap_product_ids.dart';

/// Product metadata surfaced to the UI. Wraps the underlying [ProductDetails]
/// without leaking the `in_app_purchase` type beyond this file.
class IapProduct {
  final String id;
  final String title;
  final String description;
  final String formattedPrice;

  const IapProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.formattedPrice,
  });
}

class IapService {
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<ProductDetails> _productDetails = [];
  bool available = false;
  bool _initialized = false;

  /// Called when a purchase succeeds. Argument is the product ID.
  void Function(String productId)? onPurchaseSuccess;
  void Function(String)? onPurchaseError;

  Future<void> initialize() async {
    available = await _iap.isAvailable();
    if (!available) return;

    _subscription ??= _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (_) {},
    );

    final response = await _iap.queryProductDetails(IapProductIds.all);
    _productDetails = response.productDetails;
    _initialized = true;
  }

  Future<void> ensureInitialized() async {
    if (_initialized && _productDetails.isNotEmpty) return;
    await initialize();
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final p in purchases) {
      if (p.status == PurchaseStatus.purchased ||
          p.status == PurchaseStatus.restored) {
        _iap.completePurchase(p);
        onPurchaseSuccess?.call(p.productID);
      } else if (p.status == PurchaseStatus.error) {
        onPurchaseError?.call(p.error?.message ?? 'Purchase failed');
      }
    }
  }

  IapProduct? productInfo(String id) {
    try {
      final p = _productDetails.firstWhere((e) => e.id == id);
      return IapProduct(
        id: p.id,
        title: p.title,
        description: p.description,
        formattedPrice: p.price,
      );
    } catch (_) {
      return null;
    }
  }

  bool hasProduct(String id) => _productDetails.any((p) => p.id == id);

  /// Returns true if a purchase flow was launched; false if the store is
  /// unavailable or the product is not loaded.
  Future<bool> purchase(String productId) async {
    ProductDetails? p;
    try {
      p = _productDetails.firstWhere((e) => e.id == productId);
    } catch (_) {
      return false;
    }
    final param = PurchaseParam(productDetails: p);
    // All ChromaPulse IAPs (remove_ads, vip_pass) are non-consumable.
    await _iap.buyNonConsumable(purchaseParam: param);
    return true;
  }

  Future<void> restorePurchases() async {
    if (!_initialized) await initialize();
    await _iap.restorePurchases();
  }

  void dispose() {
    _subscription?.cancel();
  }
}
