import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppScreen { menu, game, result, shop }

class ScreenNotifier extends Notifier<AppScreen> {
  @override
  AppScreen build() => AppScreen.menu;

  void go(AppScreen screen) {
    if (state == screen) return;
    state = screen;
  }
}

final screenProvider =
    NotifierProvider<ScreenNotifier, AppScreen>(ScreenNotifier.new);
