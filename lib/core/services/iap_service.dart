// Platform-aware IapService entry point.
//
// Mobile builds use the real implementation backed by in_app_purchase.
// Web builds get a no-op stub so the app compiles for Chrome.
export 'iap_product_ids.dart';
export 'iap_service_mobile.dart'
    if (dart.library.js_interop) 'iap_service_web.dart';
