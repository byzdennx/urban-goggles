import 'package:isar/isar.dart';

part 'chat_message.g.dart';

@collection
class ChatMessageEntity {
  Id id = Isar.autoIncrement;

  @Index()
  late String sessionId;

  late String role; // 'user' | 'assistant' | 'system'

  late String content;

  @Index()
  late DateTime createdAt;

  String? model;
}