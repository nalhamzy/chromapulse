// Platform-aware AdService entry point.
//
// Mobile builds get the real implementation (google_mobile_ads).
// Web builds get a no-op stub so the app compiles for Chrome.
export 'ad_service_mobile.dart'
    if (dart.library.js_interop) 'ad_service_web.dart';
