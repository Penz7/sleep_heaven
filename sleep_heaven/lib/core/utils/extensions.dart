/// Extension cho Duration - format hiển thị
extension DurationExtension on Duration {
  String get formatted {
    final minutes = inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    if (inHours > 0) {
      return '$inHours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}
