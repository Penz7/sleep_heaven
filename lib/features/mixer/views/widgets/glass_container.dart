import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../mixer_perf_tier.dart';

class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    required this.tier,
    this.padding,
    this.borderRadius = 16,
  });

  final Widget child;
  final MixerPerfTier tier;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final _GlassStyle style = _GlassStyle.forTier(tier);
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: style.sigma, sigmaY: style.sigma),
        child: Container(
          padding: padding ?? const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: Colors.white.opacityColor(style.fillOpacity),
            border: Border.all(
              color: Colors.white.opacityColor(style.borderOpacity),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _GlassStyle {
  const _GlassStyle({
    required this.sigma,
    required this.fillOpacity,
    required this.borderOpacity,
  });

  final double sigma;
  final double fillOpacity;
  final double borderOpacity;

  static _GlassStyle forTier(MixerPerfTier tier) {
    switch (tier) {
      case MixerPerfTier.capable:
        return const _GlassStyle(
          sigma: 12,
          fillOpacity: 0.05,
          borderOpacity: 0.12,
        );
      case MixerPerfTier.constrained:
        return const _GlassStyle(
          sigma: 4,
          fillOpacity: 0.03,
          borderOpacity: 0.08,
        );
    }
  }
}
