/// Product IDs for ChromaPulse in-app purchases. Kept in a tiny dependency-free
/// file so both platform service implementations and the UI layer can import
/// it without pulling in the in_app_purchase package.
class IapProductIds {
  IapProductIds._();

  static const removeAds = 'remove_ads';
  static const vipPass = 'vip_pass';

  static const all = {removeAds, vipPass};
}
