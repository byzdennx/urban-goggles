import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/automation/task_automation_service.dart';
import '../../core/constants/api_constants.dart';
import '../../core/database/isar_service.dart';
import '../../core/network/openrouter_client.dart';
import '../../core/settings/settings_provider.dart';
import 'history_controller.dart';
import '../../core/network/network_providers.dart';

class ChatMessage {
  final String id;
  final String role;
  final String content;
  ChatMessage({required this.role, required this.content})
      : id = const Uuid().v4();
}

class ChatState {
  final List<ChatMessage> messages;
  final String streaming;
  final bool loading;
  final String model;
  final String? error;
  final int? sessionId;

  const ChatState({
    this.messages = const [],
    this.streaming = '',
    this.loading = false,
    this.model = ApiConstants.chatPrimary,
    this.error,
    this.sessionId,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    String? streaming,
    bool? loading,
    String? model,
    String? error,
    int? sessionId,
  }) =>
      ChatState(
        messages: messages ?? this.messages,
        streaming: streaming ?? this.streaming,
        loading: loading ?? this.loading,
        model: model ?? this.model,
        error: error,
        sessionId: sessionId ?? this.sessionId,
      );
}

class ChatController extends StateNotifier<ChatState> {
  final OpenRouterClient _client;
  final Ref _ref;
  ChatController(this._client, this._ref) : super(const ChatState());

  IsarService get _db => _ref.read(isarServiceProvider);

  Future<void> loadSession(int sessionId) async {
    final msgs = await _db.messagesOf(sessionId);
    state = ChatState(
      sessionId: sessionId,
      messages: msgs
          .map((e) => ChatMessage(role: e.role, content: e.content))
          .toList(),
    );
  }

  Future<void> newSession() async {
    final s = await _db.createSession();
    _ref.invalidate(sessionsProvider);
    state = ChatState(sessionId: s.id);
  }

  Future<void> send(String text) async {
    final settings = _ref.read(settingsProvider);
    final model = settings.preferredModel;

    // pastikan ada session
    int sid = state.sessionId ?? 0;
    if (sid == 0) {
      final s = await _db.createSession();
      sid = s.id;
      _ref.invalidate(sessionsProvider);
      state = state.copyWith(sessionId: sid);
    }

    // simpan pesan user
    await _db.addMessage(sessionId: sid, role: 'user', content: text);

    final userMsg = ChatMessage(role: 'user', content: text);
    final updated = [...state.messages, userMsg];
    state = state.copyWith(
      messages: updated,
      loading: true,
      streaming: '',
      model: model,
      error: null,
    );

    // 🎯 Task automation: cek intent dulu (async, jangan block)
    _maybeCreateTask(text);

    final apiMsgs = updated
        .map((m) => {'role': m.role, 'content': m.content})
        .toList();

    final buf = StringBuffer();
    try {
      await for (final token in _client.streamChat(
        messages: apiMsgs,
        model: model,
      )) {
        buf.write(token);
        if (settings.streamingEnabled) {
          state = state.copyWith(streaming: buf.toString());
        }
      }
      await _finalize(sid, updated, buf.toString());
    } catch (_) {
      try {
        final buf2 = StringBuffer();
        await for (final t in _client.streamChat(
          messages: apiMsgs,
          model: ApiConstants.chatFallback,
        )) {
          buf2.write(t);
          state = state.copyWith(
              streaming: buf2.toString(), model: ApiConstants.chatFallback);
        }
        await _finalize(sid, updated, buf2.toString());
      } catch (e2) {
        state = state.copyWith(loading: false, error: e2.toString());
      }
    }
  }

  Future<void> _finalize(
      int sid, List<ChatMessage> updated, String reply) async {
    await _db.addMessage(
      sessionId: sid,
      role: 'assistant',
      content: reply,
      model: state.model,
    );
    _ref.invalidate(sessionsProvider);
    state = state.copyWith(
      messages: [...updated, ChatMessage(role: 'assistant', content: reply)],
      streaming: '',
      loading: false,
    );
  }

  void _maybeCreateTask(String text) {
    // non-blocking
    Future.microtask(() async {
      try {
        await _ref
            .read(taskAutomationProvider)
            .maybeCreateFromMessage(text);
      } catch (_) {}
    });
  }

  void clear() => state = const ChatState();
}

final chatControllerProvider =
    StateNotifierProvider<ChatController, ChatState>(
  (ref) => ChatController(ref.read(openRouterProvider), ref),
);