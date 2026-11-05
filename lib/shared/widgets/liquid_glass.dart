import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class LiquidGlass extends StatefulWidget {
  final Widget child;
  final double blur;              // default 24
  final double borderRadius;
  final EdgeInsets padding;
  final Gradient? borderGradient;
  final bool animated;            // micro pulse (opsional)
  final Color? tint;
  final double strokeWidth;

  const LiquidGlass({
    super.key,
    required this.child,
    this.blur = 24,
    this.borderRadius = 24,
    this.padding = const EdgeInsets.all(16),
    this.borderGradient,
    this.animated = false,
    this.tint,
    this.strokeWidth = 1.2,
  });

  @override
  State<LiquidGlass> createState() => _LiquidGlassState();
}

class _LiquidGlassState extends State<LiquidGlass>
    with SingleTickerProviderStateMixin {
  AnimationController? _ctrl;

  @override
  void initState() {
    super.initState();
    if (widget.animated) {
      _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 6),
      )..repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.borderRadius);
    final border = widget.borderGradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.glassHighlight,
            AppColors.glassStroke,
            Colors.transparent,
            AppColors.glassStroke.withValues(alpha: 0.3),
          ],
          stops: const [0.0, 0.35, 0.7, 1.0],
        );

    Widget core = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: widget.blur,
          sigmaY: widget.blur,
          tileMode: TileMode.mirror,
        ),
        child: Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (widget.tint ?? Colors.white).withValues(alpha: 0.10),
                (widget.tint ?? Colors.white).withValues(alpha: 0.03),
              ],
            ),
          ),
          child: widget.child,
        ),
      ),
    );

    // Gradient border tipis
    Widget bordered = Stack(
      children: [
        core,
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: radius,
                border: Border.all(
                  width: widget.strokeWidth,
                  color: Colors.transparent,
                ),
                gradient: border,
              ),
            ),
          ),
        ),
        // Inner highlight top-left (ciri liquid glass)
        Positioned.fill(
          child: IgnorePointer(
            child: Padding(
              padding: const EdgeInsets.all(1),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.35),
                      Colors.transparent,
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.25, 1.0],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );

    // Gradient border trick: pakai ShaderMask tidak perlu, cukup Container dengan gradient border
    Widget gradientBorder = CustomPaint(
      foregroundPainter: _GradientBorderPainter(
        gradient: border,
        radius: widget.borderRadius,
        width: widget.strokeWidth,
      ),
      child: bordered,
    );

    if (_ctrl != null) {
      return AnimatedBuilder(
        animation: _ctrl!,
        builder: (_, __) {
          final v = Curves.easeInOut.transform(_ctrl!.value);
          return Transform.scale(
            scale: 1.0 + v * 0.002, // super subtle, hemat GPU
            child: gradientBorder,
          );
        },
      );
    }
    return gradientBorder;
  }
}

class _GradientBorderPainter extends CustomPainter {
  final Gradient gradient;
  final double radius;
  final double width;
  _GradientBorderPainter({
    required this.gradient,
    required this.radius,
    required this.width,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height).deflate(width / 2),
      Radius.circular(radius),
    );
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientBorderPainter old) =>
      old.gradient != gradient || old.radius != radius || old.width != width;
}