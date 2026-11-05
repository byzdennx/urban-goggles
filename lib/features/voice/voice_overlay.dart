import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/liquid_glass.dart';
import '../../shared/widgets/glow_orb.dart';

/// Overlay full-screen untuk voice assistant.
/// Return String (transkrip final) lewat Navigator.pop.
class VoiceOverlay extends StatefulWidget {
  final Color accent;
  const VoiceOverlay({super.key, required this.accent});

  @override
  State<VoiceOverlay> createState() => _VoiceOverlayState();
}

class _VoiceOverlayState extends State<VoiceOverlay>
    with SingleTickerProviderStateMixin {
  final _speech = SpeechToText();
  late final AnimationController _pulse;
  String _text = '';
  bool _ready = false;
  bool _listening = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _init();
  }

  Future<void> _init() async {
    final ok = await _speech.initialize(
      onStatus: (s) {
        if (s == 'done' || s == 'notListening') {
          if (mounted) setState(() => _listening = false);
        }
      },
    );
    if (!mounted) return;
    setState(() => _ready = ok);
    if (ok) _start();
  }

  Future<void> _start() async {
    if (!_ready) return;
    setState(() => _listening = true);
    await _speech.listen(
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      onResult: (r) {
        if (!mounted) return;
        setState(() => _text = r.recognizedWords);
      },
    );
  }

  Future<void> _stopAndReturn() async {
    await _speech.stop();
    if (!mounted) return;
    Navigator.of(context).pop(_text.trim());
  }

  @override
  void dispose() {
    _pulse.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.75),
      body: Stack(
        children: [
          const Positioned.fill(child: BackgroundAurora()),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Pulse mic button
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (_, child) {
                        final scale =
                            1.0 + (_listening ? _pulse.value * 0.08 : 0);
                        return Transform.scale(scale: scale, child: child);
                      },
                      child: Container(
                        width: 132, height: 132,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              widget.accent,
                              Color.lerp(widget.accent, AppColors.cyan, 0.6)!,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.accent.withValues(alpha: 0.5),
                              blurRadius: 40, spreadRadius: 4,
                            )
                          ],
                        ),
                        child: Icon(
                          _listening ? Icons.mic : Icons.mic_off,
                          color: Colors.white, size: 52,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    LiquidGlass(
                      borderRadius: 20,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Container(
                              width: 6, height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _listening
                                    ? AppColors.success
                                    : AppColors.textLow,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _listening
                                  ? 'Mendengarkan…'
                                  : 'Selesai / tidak aktif',
                              style: t.labelSmall,
                            ),
                          ]),
                          const SizedBox(height: 10),
                          ConstrainedBox(
                            constraints:
                                const BoxConstraints(minHeight: 80, maxHeight: 200),
                            child: SingleChildScrollView(
                              child: Text(
                                _text.isEmpty
                                    ? 'Mulai bicara…'
                                    : _text,
                                style: t.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                  color: _text.isEmpty
                                      ? AppColors.textLow
                                      : AppColors.textHigh,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _CircleBtn(
                          icon: Icons.close,
                          onTap: () => Navigator.pop(context),
                        ),
                        _CircleBtn(
                          icon: _listening ? Icons.stop : Icons.play_arrow,
                          primary: true,
                          accent: widget.accent,
                          onTap: _listening
                              ? () async {
                                  await _speech.stop();
                                  if (mounted) {
                                    setState(() => _listening = false);
                                  }
                                }
                              : _start,
                        ),
                        _CircleBtn(
                          icon: Icons.check,
                          primary: true,
                          accent: AppColors.success,
                          onTap: _stopAndReturn,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool primary;
  final Color? accent;
  const _CircleBtn({
    required this.icon,
    required this.onTap,
    this.primary = false,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60, height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: primary
              ? (accent ?? AppColors.violet)
              : Colors.white.withValues(alpha: 0.1),
          border: primary
              ? null
              : Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Icon(icon,
            color: Colors.white, size: 26),
      ),
    );
  }
}