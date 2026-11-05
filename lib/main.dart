import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/database/isar_service.dart';
import 'core/perf/performance_guard.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PerformanceGuard.install();
  await dotenv.load(fileName: '.env');

  final isar = IsarService();
  await isar.open();

  runApp(
    ProviderScope(
      overrides: [isarServiceProvider.overrideWithValue(isar)],
      child: const ExAssistApp(),
    ),
  );
}