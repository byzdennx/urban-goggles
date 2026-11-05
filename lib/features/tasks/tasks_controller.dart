import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/collections/task_item.dart';
import '../../core/database/isar_service.dart';

final tasksStreamProvider = StreamProvider.autoDispose<List<TaskItemEntity>>(
  (ref) => ref.read(isarServiceProvider).watchTasks(),
);

class TasksActions {
  final IsarService db;
  TasksActions(this.db);

  Future<void> toggle(int id) => db.toggleTask(id);
  Future<void> delete(int id) => db.deleteTask(id);
}

final tasksActionsProvider = Provider<TasksActions>(
  (ref) => TasksActions(ref.read(isarServiceProvider)),
);