import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'openrouter_client.dart';

final openRouterProvider = Provider<OpenRouterClient>((_) => OpenRouterClient());