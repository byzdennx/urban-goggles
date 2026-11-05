import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../constants/api_constants.dart';

class OpenRouterClient {
  late final Dio _dio;

  OpenRouterClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        headers: {
          'Authorization': 'Bearer ${dotenv.env['OPENROUTER_API_KEY']}',
          'HTTP-Referer': dotenv.env['OPENROUTER_REFERER'] ?? '',
          'X-Title': dotenv.env['OPENROUTER_TITLE'] ?? 'ExAssist',
          'Content-Type': 'application/json',
        },
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 120),
        sendTimeout: const Duration(seconds: 30),
      ),
    );

    // Logging ringan — matikan di release
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (e, handler) {
          // Bisa tambahkan retry logic global di sini
          handler.next(e);
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // STREAMING CHAT — untuk chat interaktif (token muncul bertahap)
  // ═══════════════════════════════════════════════════════════════════════
  Stream<String> streamChat({
    required List<Map<String, dynamic>> messages,
    String? model,
    double temperature = 0.7,
    int? maxTokens,
  }) async* {
    final response = await _dio.post(
      '/chat/completions',
      data: {
        'model': model ?? ApiConstants.chatPrimary,
        'messages': messages,
        'temperature': temperature,
        if (maxTokens != null) 'max_tokens': maxTokens,
        'stream': true,
      },
      options: Options(responseType: ResponseType.stream),
    );

    final stream = response.data.stream as Stream<List<int>>;
    final buffer = StringBuffer();

    await for (final chunk in stream) {
      buffer.write(utf8.decode(chunk, allowMalformed: true));
      final raw = buffer.toString();
      final lines = raw.split('\n');
      buffer.clear();
      buffer.write(lines.removeLast());

      for (final line in lines) {
        if (!line.startsWith('data: ')) continue;
        final data = line.substring(6).trim();
        if (data == '[DONE]') return;
        try {
          final j = jsonDecode(data);
          final delta = j['choices']?[0]?['delta']?['content'];
          if (delta is String && delta.isNotEmpty) yield delta;
        } catch (_) {
          // skip malformed line (kadang OpenRouter kirim heartbeat)
        }
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // NON-STREAMING CHAT — untuk intent parser, summarizer, dll
  // ═══════════════════════════════════════════════════════════════════════
  Future<String> completeChat({
    required List<Map<String, dynamic>> messages,
    String? model,
    double temperature = 0.7,
    int? maxTokens,
  }) async {
    final response = await _dio.post(
      '/chat/completions',
      data: {
        'model': model ?? ApiConstants.chatPrimary,
        'messages': messages,
        'temperature': temperature,
        if (maxTokens != null) 'max_tokens': maxTokens,
        'stream': false,
      },
    );

    final choices = response.data['choices'];
    if (choices is! List || choices.isEmpty) {
      throw Exception('OpenRouter: response kosong');
    }
    final content = choices[0]['message']?['content'];
    if (content is! String) {
      throw Exception('OpenRouter: format response tidak valid');
    }
    return content.trim();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // EMBEDDING — untuk memory / RAG
  // ═══════════════════════════════════════════════════════════════════════
  Future<List<double>> createEmbedding(
    String text, {
    String? model,
  }) async {
    final response = await _dio.post(
      '/embeddings',
      data: {
        'model': model ?? ApiConstants.embedSmall,
        'input': text,
      },
    );
    final embedding = response.data['data']?[0]?['embedding'];
    if (embedding is! List) {
      throw Exception('OpenRouter: embedding tidak valid');
    }
    return embedding.map((e) => (e as num).toDouble()).toList();
  }

  Future<List<List<double>>> createEmbeddingsBatch(
    List<String> texts, {
    String? model,
  }) async {
    final response = await _dio.post(
      '/embeddings',
      data: {
        'model': model ?? ApiConstants.embedSmall,
        'input': texts,
      },
    );
    final data = response.data['data'] as List;
    return data
        .map((e) => (e['embedding'] as List)
            .map((v) => (v as num).toDouble())
            .toList())
        .toList();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // RERANK — pilih konteks terbaik dari kandidat
  // ═══════════════════════════════════════════════════════════════════════
  Future<List<Map<String, dynamic>>> rerank({
    required String query,
    required List<String> documents,
    String? model,
    int? topN,
  }) async {
    final response = await _dio.post(
      '/rerank',
      data: {
        'model': model ?? ApiConstants.reranker,
        'query': query,
        'documents': documents,
        if (topN != null) 'top_n': topN,
      },
    );
    final results = response.data['results'];
    if (results is! List) return const [];
    return results.cast<Map<String, dynamic>>();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // VISION — analisis gambar (base64)
  // ═══════════════════════════════════════════════════════════════════════
  Future<String> analyzeImage({
    required String base64Image,
    required String prompt,
    String? model,
  }) async {
    final response = await _dio.post(
      '/chat/completions',
      data: {
        'model': model ?? ApiConstants.vision,
        'messages': [
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': prompt},
              {
                'type': 'image_url',
                'image_url': {'url': 'data:image/jpeg;base64,$base64Image'},
              },
            ],
          },
        ],
        'stream': false,
      },
    );
    final content = response.data['choices'][0]['message']['content'];
    return (content as String).trim();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // UTILITY — list model yang tersedia (debug)
  // ═══════════════════════════════════════════════════════════════════════
  Future<List<Map<String, dynamic>>> listModels() async {
    final response = await _dio.get('/models');
    final data = response.data['data'];
    if (data is! List) return const [];
    return data.cast<Map<String, dynamic>>();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // DEBUG — cek koneksi & API key valid
  // ═══════════════════════════════════════════════════════════════════════
  Future<bool> ping() async {
    try {
      await _dio.get('/models');
      return true;
    } catch (_) {
      return false;
    }
  }
}