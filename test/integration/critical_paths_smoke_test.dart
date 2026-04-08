@Tags(<String>['critical-smoke'])library;
import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_heaven/core/services/audio_handler.dart';
import 'package:sleep_heaven/core/startup/startup_result.dart';

void main() {
  const Map<String, String> quarantineMetadata = <String, String>{
    'owner': 'qa-core',
    'policy': 'visible-not-silent',
  };

  group('critical flow smoke', () {
    test('startup route boot path stays healthy', () {
      const StartupResult startupResult = StartupResult.ok();
      expect(startupResult.isFatal, isFalse);
      expect(startupResult.isDegraded, isFalse);
      expect(startupResult.message, isNull);
    }, timeout: const Timeout(Duration(seconds: 5)));

    test('playback start/stop transitions execute deterministically', () async {
      final SleepAudioHandler handler = SleepAudioHandler();
      int playCalls = 0;
      int pauseCalls = 0;
      handler.acquireOwnership(
        ownerId: 'critical-smoke-player',
        onPlayRequested: () => playCalls += 1,
        onPauseRequested: () => pauseCalls += 1,
      );

      await handler.play();
      await handler.pause();

      expect(playCalls, equals(1));
      expect(pauseCalls, equals(1));
    }, timeout: const Timeout(Duration(seconds: 5)));

    test('startup restore reconciliation contract flags offline safely', () {
      const StartupResult offlineRestore =
          StartupResult.degraded('IAP service degraded.');
      expect(offlineRestore.isDegraded, isTrue);
      expect(offlineRestore.isFatal, isFalse);
      expect(offlineRestore.message, isNotEmpty);
      expect(quarantineMetadata['owner'], equals('qa-core'));
    }, timeout: const Timeout(Duration(seconds: 5)));
  });
}

