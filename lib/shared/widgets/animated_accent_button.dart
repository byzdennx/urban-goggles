import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AnimatedAccentButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final Gradient gradient;
  final VoidCallback? onTap;
  final bool compact;

  const AnimatedAccentButton({
    super.key,
    required this.label,
    required this.gradient,
    this.icon,
    this.onTap,
    this.compact = false,
  });

  @override
  State<AnimatedAccentButton> createState() => _AnimatedAccentButtonState();
}

class _AnimatedAccentButtonState extends State<AnimatedAccentButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) {
        setState(() => _down = false);
        widget.onTap?.call();
      },
      child: AnimatedScale(
        scale: _down ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.compact ? 14 : 20,
            vertical: widget.compact ? 10 : 14,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: widget.gradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.violet.withValues(alpha: 0.35),
                blurRadius: 20, spreadRadius: -6,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 18, color: Colors.white),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}