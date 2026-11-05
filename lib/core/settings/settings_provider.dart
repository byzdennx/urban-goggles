import 'package:flutter/material.dart' show Color;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settings_model.dart';
import 'settings_storage.dart';

class SettingsController extends StateNotifier<AppSettings> {
  final SettingsStorage _storage;
  SettingsController(this._storage) : super(const AppSettings()) {
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    state = await _storage.load();
  }

  Future<void> _apply(AppSettings next) async {
    state = next;
    await _storage.save(next);
  }

  Future<void> setAccent(Color c) => _apply(state.copyWith(accentColor: c));
  Future<void> setBubbleRadius(double r) =>
      _apply(state.copyWith(bubbleRadius: r.clamp(6, 28)));
  Future<void> setMarkdown(bool on) => _apply(state.copyWith(markdownEnabled: on));
  Future<void> setStreaming(bool on) => _apply(state.copyWith(streamingEnabled: on));
  Future<void> setSound(bool on) => _apply(state.copyWith(soundOnResponse: on));
  Future<void> setPreferredModel(String m) =>
      _apply(state.copyWith(preferredModel: m));
  Future<void> setGlassBlur(double b) =>
      _apply(state.copyWith(glassBlur: b.clamp(0, 40)));
  Future<void> setLiquidAnim(bool on) =>
      _apply(state.copyWith(liquidAnimationOn: on));

  Future<void> resetAll() => _apply(const AppSettings());
}

final settingsStorageProvider = Provider<SettingsStorage>((_) => SettingsStorage());

final settingsProvider =
    StateNotifierProvider<SettingsController, AppSettings>(
  (ref) => SettingsController(ref.read(settingsStorageProvider)),
);