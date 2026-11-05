import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/collections/chat_session.dart';
import '../../core/database/collections/chat_message.dart';
import '../../core/database/isar_service.dart';

final sessionsProvider = FutureProvider.autoDispose<List<ChatSessionEntity>>(
  (ref) => ref.read(isarServiceProvider).allSessions(),
);

final messagesOfSessionProvider = FutureProvider.autoDispose
    .family<List<ChatMessageEntity>, int>((ref, sessionId) {
  return ref.read(isarServiceProvider).messagesOf(sessionId);
});

class HistoryActions {
  final IsarService db;
  HistoryActions(this.db);

  Future<ChatSessionEntity> create() => db.createSession();
  Future<void> delete(int id) => db.deleteSession(id);
  Future<void> rename(int id, String title) => db.renameSession(id, title);
}

final historyActionsProvider = Provider<HistoryActions>(
  (ref) => HistoryActions(ref.read(isarServiceProvider)),
);