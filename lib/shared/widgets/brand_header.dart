import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'liquid_glass.dart';

class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return LiquidGlass(
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo mark: dua lingkaran overlap (Ex x Epann)
          SizedBox(
            width: 26, height: 26,
            child: Stack(children: [
              Positioned(left: 0, top: 4,
                child: _dot(AppColors.violet)),
              Positioned(left: 9, top: 0,
                child: _dot(AppColors.cyan, .85)),
              Positioned(left: 14, top: 8,
                child: _dot(AppColors.amethyst, .75)),
            ]),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ExAssist',
                style: Theme.of(context).textTheme.headlineSmall),
              Text('by My Ex × EpannXD',
                style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dot(Color c, [double a = 1]) => Container(
        width: 12, height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: c.withValues(alpha: a),
        ),
      );
}