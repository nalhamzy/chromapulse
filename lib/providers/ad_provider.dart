import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chromapulse/core/services/ad_service.dart';

final adServiceProvider = Provider<AdService>((ref) {
  final svc = AdService();
  svc.initialize();
  ref.onDispose(svc.dispose);
  return svc;
});
