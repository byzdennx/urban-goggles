import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../core/theme/app_colors.dart';

class LiquidRefractionGlass extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;
  final Color tint;
  final double intensity;
  final double waveScale;
  final double blurStrength;
  final bool animated;

  const LiquidRefractionGlass({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.padding = const EdgeInsets.all(16),
    this.tint = AppColors.violet,
    this.intensity = 0.8,
    this.waveScale = 1.4,
    this.blurStrength = 1.0,
    this.animated = true,
  });

  @override
  State<LiquidRefractionGlass> createState() => _LiquidRefractionGlassState();
}

class _LiquidRefractionGlassState extends State<LiquidRefractionGlass>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  ui.FragmentShader? _shader;
  Duration _elapsed = Duration.zero;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _loadShader();
    _ticker = createTicker(_onTick)..start();
  }

  Future<void> _loadShader() async {
    try {
      final program = await ui.FragmentProgram.fromAsset(
        'shaders/liquid_refraction.frag',
      );
      if (!mounted) return;
      setState(() {
        _shader = program.fragmentShader();
        _ready = true;
      });
    } catch (e) {
      debugPrint('[LiquidShader] gagal load: $e — pakai fallback blur');
      if (mounted) setState(() => _ready = false);
    }
  }

  void _onTick(Duration elapsed) {
    if (!mounted || !_ready) return;
    // Throttle ke ~30fps untuk hemat GPU
    if ((elapsed - _elapsed).inMilliseconds < 33) return;
    _elapsed = elapsed;
    setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    _shader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.borderRadius);
    final tintColor = widget.tint.withValues(alpha: 0.35);

    return ClipRRect(
      borderRadius: radius,
      child: CustomPaint(
        foregroundPainter: _ready
            ? _LiquidShaderPainter(
                shader: _shader!,
                time: _elapsed.inMilliseconds / 1000.0,
                tint: tintColor,
                intensity: widget.intensity,
                waveScale: widget.waveScale,
                blurStrength: widget.blurStrength,
              )
            : null,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(
            sigmaX: 18 * widget.blurStrength,
            sigmaY: 18 * widget.blurStrength,
          ),
          child: Container(
            padding: widget.padding,
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.10),
                  Colors.white.withValues(alpha: 0.03),
                ],
              ),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class _LiquidShaderPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final double time;
  final Color tint;
  final double intensity;
  final double waveScale;
  final double blurStrength;

  _LiquidShaderPainter({
    required this.shader,
    required this.time,
    required this.tint,
    required this.intensity,
    required this.waveScale,
    required this.blurStrength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setFloat(2, time);
    shader.setFloat(3, intensity);
    shader.setFloat(4, tint.r);
    shader.setFloat(5, tint.g);
    shader.setFloat(6, tint.b);
    shader.setFloat(7, tint.a);
    shader.setFloat(8, waveScale);
    shader.setFloat(9, blurStrength);

    final paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _LiquidShaderPainter old) =>
      old.time != time ||
      old.tint != tint ||
      old.intensity != intensity;
}