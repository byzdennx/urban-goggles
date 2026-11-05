import 'package:isar/isar.dart';
import 'chat_message.dart';           // ← WAJIB: agar ChatMessageEntity dikenali

part 'chat_session.g.dart';

@collection
class ChatSessionEntity {
  Id id = Isar.autoIncrement;

  late String title;

  @Index()
  late DateTime createdAt;

  late DateTime updatedAt;

  String? model;

  bool pinned = false;

  final messages = IsarLinks<ChatMessageEntity>();
}