enum MixerPerfTier { capable, constrained }

class MixerPerfEvidence {
  const MixerPerfEvidence({
    required this.p95UiFrameMs,
    required this.p95RasterFrameMs,
    required this.jankRatio,
  });

  final double p95UiFrameMs;
  final double p95RasterFrameMs;
  final double jankRatio;
}

class MixerPerfTierPolicy {
  static const double _uiFrameLimitMs = 12.0;
  static const double _rasterFrameLimitMs = 12.0;
  static const double _jankRatioLimit = 0.03;

  static MixerPerfTier resolve(MixerPerfEvidence evidence) {
    if (evidence.p95UiFrameMs > _uiFrameLimitMs ||
        evidence.p95RasterFrameMs > _rasterFrameLimitMs ||
        evidence.jankRatio > _jankRatioLimit) {
      return MixerPerfTier.constrained;
    }
    return MixerPerfTier.capable;
  }
}
