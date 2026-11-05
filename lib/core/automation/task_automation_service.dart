import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/collections/task_item.dart';
import '../database/isar_service.dart';
import '../network/network_providers.dart';   // ← TAMBAH INI
import '../network/openrouter_client.dart';
import 'intent_parser.dart';

class TaskAutomationService {
  final IsarService db;
  final IntentParser parser;

  TaskAutomationService(this.db, this.parser);

  Future<TaskItemEntity?> maybeCreateFromMessage(String message) async {
    final intent = await parser.parse(message);
    if (intent.type == 'chat') return null;

    final type = switch (intent.type) {
      'reminder' => TaskType.reminder,
      'note' => TaskType.note,
      'todo' => TaskType.todo,
      _ => TaskType.todo,
    };

    return db.addTask(
      title: intent.title ?? message,
      description: intent.description,
      type: type,
      dueAt: intent.dueAt,
    );
  }
}

final intentParserProvider = Provider<IntentParser>(
  (ref) => IntentParser(ref.read(openRouterProvider)),
);

final taskAutomationProvider = Provider<TaskAutomationService>(
  (ref) => TaskAutomationService(
    ref.read(isarServiceProvider),
    ref.read(intentParserProvider),
  ),
);