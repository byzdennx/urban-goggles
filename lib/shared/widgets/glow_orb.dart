import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class GlowOrb extends StatelessWidget {
  final Color color;
  final double size;
  final Alignment alignment;
  final double opacity;

  const GlowOrb({
    super.key,
    required this.color,
    this.size = 320,
    this.alignment = Alignment.topLeft,
    this.opacity = 0.35,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: alignment,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: opacity),
                color.withValues(alpha: 0.0),
              ],
              stops: const [0.0, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}

class BackgroundAurora extends StatelessWidget {
  const BackgroundAurora({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Stack(
          children: [
            GlowOrb(
              color: AppColors.violet,
              size: 420,
              alignment: const Alignment(-0.9, -0.8),
              opacity: 0.32,
            ),
            GlowOrb(
              color: AppColors.cyan,
              size: 380,
              alignment: const Alignment(0.9, 0.6),
              opacity: 0.22,
            ),
            GlowOrb(
              color: AppColors.amethyst,
              size: 260,
              alignment: const Alignment(0.6, -1.0),
              opacity: 0.18,
            ),
          ],
        ),
      ),
    );
  }
}