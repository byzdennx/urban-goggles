import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/routing/app_router.dart';
import 'core/settings/settings_provider.dart';
import 'core/theme/app_theme.dart';

class ExAssistApp extends ConsumerWidget {
  const ExAssistApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Rebuild theme ketika aksen berubah
    final settings = ref.watch(settingsProvider);
    final baseTheme = AppTheme.dark;

    return MaterialApp.router(
      title: 'ExAssist',
      debugShowCheckedModeBanner: false,
      theme: baseTheme.copyWith(
        colorScheme: baseTheme.colorScheme.copyWith(
          primary: settings.accentColor,
          secondary: settings.accentColor,
        ),
      ),
      routerConfig: appRouter,
    );
  }
}