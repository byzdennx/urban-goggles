import 'package:isar/isar.dart';

part 'task_item.g.dart';

enum TaskType { reminder, note, todo }

@collection
class TaskItemEntity {
  Id id = Isar.autoIncrement;

  late String title;

  String? description;

  @Enumerated(EnumType.name)
  late TaskType type;

  DateTime? dueAt;

  @Index()
  bool done = false;

  late DateTime createdAt;

  String? sourceMessageId;
}