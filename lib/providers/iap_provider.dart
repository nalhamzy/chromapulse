import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chromapulse/core/services/iap_service.dart';

final iapServiceProvider = Provider<IapService>((ref) {
  final svc = IapService();
  svc.initialize();
  ref.onDispose(svc.dispose);
  return svc;
});
