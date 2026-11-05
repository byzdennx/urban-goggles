import 'package:flutter/material.dart';

/// Semua preferensi aplikasi di satu tempat, immutable.
@immutable
class AppSettings {
  final Color accentColor;
  final double bubbleRadius;      // 6.0 – 28.0
  final bool markdownEnabled;
  final bool streamingEnabled;
  final bool soundOnResponse;
  final String preferredModel;
  final double glassBlur;         // 0 – 40
  final bool liquidAnimationOn;

  const AppSettings({
    this.accentColor = const Color(0xFF8B5CF6), // amethyst default
    this.bubbleRadius = 18.0,
    this.markdownEnabled = true,
    this.streamingEnabled = true,
    this.soundOnResponse = false,
    this.preferredModel = 'recursive/flint-v1.0:free',
    this.glassBlur = 24.0,
    this.liquidAnimationOn = false,
  });

  AppSettings copyWith({
    Color? accentColor,
    double? bubbleRadius,
    bool? markdownEnabled,
    bool? streamingEnabled,
    bool? soundOnResponse,
    String? preferredModel,
    double? glassBlur,
    bool? liquidAnimationOn,
  }) {
    return AppSettings(
      accentColor: accentColor ?? this.accentColor,
      bubbleRadius: bubbleRadius ?? this.bubbleRadius,
      markdownEnabled: markdownEnabled ?? this.markdownEnabled,
      streamingEnabled: streamingEnabled ?? this.streamingEnabled,
      soundOnResponse: soundOnResponse ?? this.soundOnResponse,
      preferredModel: preferredModel ?? this.preferredModel,
      glassBlur: glassBlur ?? this.glassBlur,
      liquidAnimationOn: liquidAnimationOn ?? this.liquidAnimationOn,
    );
  }

  /// Warna gradien turunan dari aksen pilihan user.
  LinearGradient get accentGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          accentColor,
          Color.lerp(accentColor, const Color(0xFF22D3EE), 0.5)!,
          const Color(0xFF22D3EE),
        ],
      );

  Map<String, dynamic> toJson() => {
        'accentColor': accentColor.toARGB32(),
        'bubbleRadius': bubbleRadius,
        'markdownEnabled': markdownEnabled,
        'streamingEnabled': streamingEnabled,
        'soundOnResponse': soundOnResponse,
        'preferredModel': preferredModel,
        'glassBlur': glassBlur,
        'liquidAnimationOn': liquidAnimationOn,
      };

  factory AppSettings.fromJson(Map<String, dynamic> j) => AppSettings(
        accentColor: Color(j['accentColor'] as int? ?? 0xFF8B5CF6),
        bubbleRadius: (j['bubbleRadius'] as num?)?.toDouble() ?? 18.0,
        markdownEnabled: j['markdownEnabled'] as bool? ?? true,
        streamingEnabled: j['streamingEnabled'] as bool? ?? true,
        soundOnResponse: j['soundOnResponse'] as bool? ?? false,
        preferredModel:
            j['preferredModel'] as String? ?? 'recursive/flint-v1.0:free',
        glassBlur: (j['glassBlur'] as num?)?.toDouble() ?? 24.0,
        liquidAnimationOn: j['liquidAnimationOn'] as bool? ?? false,
      );
}