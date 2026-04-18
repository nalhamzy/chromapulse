/// Product IDs for ChromaPulse in-app purchases. Kept in a tiny dependency-free
/// file so both platform service implementations and the UI layer can import
/// it without pulling in the in_app_purchase package.
class IapProductIds {
  IapProductIds._();

  // Namespaced because ASC product IDs are globally unique per Apple team.
  // Color Chaos already claims `remove_ads` / `vip_pass` in the Ideal AI team.
  static const removeAds = 'chromapulse_remove_ads';
  static const vipPass = 'chromapulse_vip_pass';

  static const all = {removeAds, vipPass};
}
