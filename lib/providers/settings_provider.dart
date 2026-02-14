import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class AppSettings {
  final bool showReference;
  final bool showTranslation;
  final bool keepScreenAwake;

  const AppSettings({
    this.showReference = true,
    this.showTranslation = true,
    this.keepScreenAwake = false,
  });

  AppSettings copyWith({
    bool? showReference,
    bool? showTranslation,
    bool? keepScreenAwake,
  }) {
    return AppSettings(
      showReference: showReference ?? this.showReference,
      showTranslation: showTranslation ?? this.showTranslation,
      keepScreenAwake: keepScreenAwake ?? this.keepScreenAwake,
    );
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    _loadSettings();
    return const AppSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final showReference = prefs.getBool('showReference') ?? true;
    final showTranslation = prefs.getBool('showTranslation') ?? true;
    final keepScreenAwake = prefs.getBool('keepScreenAwake') ?? false;

    state = AppSettings(
      showReference: showReference,
      showTranslation: showTranslation,
      keepScreenAwake: keepScreenAwake,
    );

    // Apply wakelock on startup
    if (keepScreenAwake) {
      await WakelockPlus.enable();
    }
  }

  Future<void> setShowReference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showReference', value);
    state = state.copyWith(showReference: value);
  }

  Future<void> setShowTranslation(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showTranslation', value);
    state = state.copyWith(showTranslation: value);
  }

  Future<void> setKeepScreenAwake(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('keepScreenAwake', value);
    if (value) {
      await WakelockPlus.enable();
    } else {
      await WakelockPlus.disable();
    }
    state = state.copyWith(keepScreenAwake: value);
  }
}

// ── View Mode (grid vs list) ──

final viewModeProvider =
    NotifierProvider<ViewModeNotifier, bool>(ViewModeNotifier.new);

class ViewModeNotifier extends Notifier<bool> {
  @override
  bool build() => true; // true = grid

  void toggle() => state = !state;

  void set(bool value) => state = value;
}
