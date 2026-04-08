/// Helper cho xử lý audio
class AudioHelpers {
  AudioHelpers._();

  /// Fade volume từ current xuống 0 trong duration (ms)
  static Future<void> fadeOut(
    double currentVolume,
    int durationMs,
    Future<void> Function(double) setVolume,
  ) async {
    const steps = 20;
    final stepDuration = durationMs ~/ steps;
    final stepDecrement = currentVolume / steps;

    for (var i = 0; i < steps; i++) {
      await Future<void>.delayed(Duration(milliseconds: stepDuration));
      final newVol = (currentVolume - (stepDecrement * (i + 1))).clamp(
        0.0,
        1.0,
      );
      await setVolume(newVol);
    }
  }
}
