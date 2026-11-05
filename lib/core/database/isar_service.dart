import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'collections/chat_session.dart';
import 'collections/chat_message.dart';
import 'collections/task_item.dart';

class IsarService {
  late final Isar _isar;

  Future<void> open() async {
    if (Isar.instanceNames.isNotEmpty) {
      _isar = Isar.getInstance()!;
      return;
    }
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [ChatSessionEntitySchema, ChatMessageEntitySchema, TaskItemEntitySchema],
      directory: dir.path,
      name: 'exassist',
    );
  }

  Isar get db => _isar;

  // === Sessions ===
  Future<ChatSessionEntity> createSession({String title = 'Percakapan baru'}) async {
    final s = ChatSessionEntity()
      ..title = title
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();
    await _isar.writeTxn(() async {
      await _isar.chatSessionEntitys.put(s);
    });
    return s;
  }

  Future<List<ChatSessionEntity>> allSessions() async {
    return _isar.chatSessionEntitys
        .where()
        .sortByUpdatedAtDesc()
        .findAll();
  }

  Future<void> deleteSession(int id) async {
    await _isar.writeTxn(() async {
      await _isar.chatMessageEntitys
          .filter()
          .sessionIdEqualTo(id.toString())
          .deleteAll();
      await _isar.chatSessionEntitys.delete(id);
    });
  }

  Future<void> renameSession(int id, String title) async {
    final s = await _isar.chatSessionEntitys.get(id);
    if (s == null) return;
    s.title = title;
    s.updatedAt = DateTime.now();
    await _isar.writeTxn(() async {
      await _isar.chatSessionEntitys.put(s);
    });
  }

  // === Messages ===
  Future<List<ChatMessageEntity>> messagesOf(int sessionId) async {
    return _isar.chatMessageEntitys
        .filter()
        .sessionIdEqualTo(sessionId.toString())
        .sortByCreatedAt()
        .findAll();
  }

  Future<ChatMessageEntity> addMessage({
    required int sessionId,
    required String role,
    required String content,
    String? model,
  }) async {
    final m = ChatMessageEntity()
      ..sessionId = sessionId.toString()
      ..role = role
      ..content = content
      ..model = model
      ..createdAt = DateTime.now();
    await _isar.writeTxn(() async {
      await _isar.chatMessageEntitys.put(m);
      final s = await _isar.chatSessionEntitys.get(sessionId);
      if (s != null) {
        s.updatedAt = DateTime.now();
        if (role == 'user' && s.title == 'Percakapan baru') {
          s.title = content.length > 40
              ? '${content.substring(0, 40)}…'
              : content;
        }
        await _isar.chatSessionEntitys.put(s);
      }
    });
    return m;
  }

  // === Tasks ===
  Future<TaskItemEntity> addTask({
    required String title,
    String? description,
    required TaskType type,
    DateTime? dueAt,
    String? sourceMessageId,
  }) async {
    final t = TaskItemEntity()
      ..title = title
      ..description = description
      ..type = type
      ..dueAt = dueAt
      ..createdAt = DateTime.now()
      ..sourceMessageId = sourceMessageId;
    await _isar.writeTxn(() async {
      await _isar.taskItemEntitys.put(t);
    });
    return t;
  }

  Stream<List<TaskItemEntity>> watchTasks() {
    return _isar.taskItemEntitys
        .filter()
        .doneEqualTo(false)
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true);
  }

  Future<void> toggleTask(int id) async {
    final t = await _isar.taskItemEntitys.get(id);
    if (t == null) return;
    t.done = !t.done;
    await _isar.writeTxn(() async {
      await _isar.taskItemEntitys.put(t);
    });
  }

  Future<void> deleteTask(int id) async {
    await _isar.writeTxn(() async {
      await _isar.taskItemEntitys.delete(id);
    });
  }
}

final isarServiceProvider = Provider<IsarService>((_) => IsarService());