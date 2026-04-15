/// Web stub — all methods are no-ops so the app compiles for Chrome without
/// pulling in_app_purchase (which doesn't support web).
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
  bool available = false;

  void Function(String productId)? onPurchaseSuccess;
  void Function(String)? onPurchaseError;

  Future<void> initialize() async {}
  Future<void> ensureInitialized() async {}

  IapProduct? productInfo(String id) => null;
  bool hasProduct(String id) => false;

  Future<bool> purchase(String productId) async => false;
  Future<void> restorePurchases() async {}

  void dispose() {}
}
