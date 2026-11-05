import 'dart:convert';
import '../network/openrouter_client.dart';

class ParsedIntent {
  final String type; // 'reminder' | 'note' | 'todo' | 'chat'
  final String? title;
  final String? description;
  final DateTime? dueAt;
  final String? raw;

  ParsedIntent({
    required this.type,
    this.title,
    this.description,
    this.dueAt,
    this.raw,
  });

  factory ParsedIntent.chat() => ParsedIntent(type: 'chat');
}

class IntentParser {
  final OpenRouterClient client;
  IntentParser(this.client);

  static const _systemPrompt = '''
Kamu adalah intent parser untuk aplikasi asisten pribadi ExAssist.
Tugasmu: dari pesan user, ekstrak apakah user ingin:
- "reminder" (mengingatkan sesuatu, biasanya ada waktu)
- "note" (catatan tanpa waktu spesifik)
- "todo" (daftar tugas tanpa waktu)
- "chat" (bukan task, hanya ngobrol/tanya)

Balas HANYA dengan JSON valid, tanpa markdown, format:
{"type":"reminder|note|todo|chat","title":"...","description":"...","due_iso":"2025-01-01T08:00:00"}

Aturan:
- title: singkat, maksimal 8 kata, tanpa "ingatkan saya untuk"
- due_iso: ISO8601 dalam waktu lokal user (sekarang: {{NOW}}), nullable
- kalau type=chat, title & due_iso boleh null
- Bahasa user: Indonesia atau Inggris, jawab dengan bahasa yang sama untuk title
''';

  Future<ParsedIntent> parse(String userMessage) async {
    final now = DateTime.now().toIso8601String();
    final prompt = _systemPrompt.replaceAll('{{NOW}}', now);

    final response = await client.completeChat(
      messages: [
        {'role': 'system', 'content': prompt},
        {'role': 'user', 'content': userMessage},
      ],
      model: 'recursive/flint-v1.0:free',
      temperature: 0.1,
    );

    try {
      final cleaned = _extractJson(response);
      final j = jsonDecode(cleaned) as Map<String, dynamic>;
      final type = (j['type'] ?? 'chat').toString();
      if (type == 'chat') return ParsedIntent.chat();
      return ParsedIntent(
        type: type,
        title: j['title']?.toString(),
        description: j['description']?.toString(),
        dueAt: j['due_iso'] != null
            ? DateTime.tryParse(j['due_iso'].toString())
            : null,
        raw: userMessage,
      );
    } catch (_) {
      return ParsedIntent.chat();
    }
  }

  String _extractJson(String s) {
    final start = s.indexOf('{');
    final end = s.lastIndexOf('}');
    if (start >= 0 && end > start) return s.substring(start, end + 1);
    return '{}';
  }
}