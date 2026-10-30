import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mode id the Progress screen should open on, set by the Stats screen when a
/// player taps a specific mode. Null means "pick the sensible default".
class HistoryFocusNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void focus(String? modeId) => state = modeId;
}

final historyFocusProvider = NotifierProvider<HistoryFocusNotifier, String?>(
  HistoryFocusNotifier.new,
);
