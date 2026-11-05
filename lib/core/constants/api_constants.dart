class ApiConstants {
  static const baseUrl = 'https://openrouter.ai/api/v1';

  // Chat
  static const chatPrimary  = 'recursive/flint-v1.0:free';
  static const chatFallback = 'xingchen-agi/xing4.0-29b-a4b:free';
  static const chatLight    = 'respan/span-01-lite:free';
  static const codeModel    = 'cohere/north-mini-code:free';
  static const vision       = 'nvidia/nemotron-3.5-super-vl:free';

  // Embedding / Rerank
  static const embedSmall = 'nvidia/nemotron-3-embed-1b:free';
  static const embedLarge = 'nvidia/nemotron-3.5-embed-8b:free';
  static const reranker   = 'nvidia/nemotron-3.5-rerank-8b:free';
}

enum AssistantTask { chat, code, summarize, vision }

class ModelRouter {
  static String pick(AssistantTask t) {
    switch (t) {
      case AssistantTask.chat:      return ApiConstants.chatPrimary;
      case AssistantTask.code:      return ApiConstants.codeModel;
      case AssistantTask.summarize: return ApiConstants.chatLight;
      case AssistantTask.vision:    return ApiConstants.vision;
    }
  }
}