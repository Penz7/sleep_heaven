@Tags(<String>['fast'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_heaven/core/services/audio_handler.dart';

void main() {
  test(
    'player ownership receives control events when active',
    () async {
      final SleepAudioHandler handler = SleepAudioHandler();
      int playCalls = 0;
      int pauseCalls = 0;

      final int token = handler.acquireOwnership(
        ownerId: 'player',
        onPlayRequested: () => playCalls += 1,
        onPauseRequested: () => pauseCalls += 1,
      );

      await handler.play();
      await handler.pause();

      expect(handler.isOwnerActive('player', token), isTrue);
      expect(playCalls, equals(1));
      expect(pauseCalls, equals(1));
    },
    timeout: const Timeout(Duration(seconds: 5)),
  );

  test(
    'mixer takeover invalidates prior player callback routing',
    () async {
      final SleepAudioHandler handler = SleepAudioHandler();
      int playerCalls = 0;
      int mixerCalls = 0;

      final int playerToken = handler.acquireOwnership(
        ownerId: 'player',
        onPlayRequested: () => playerCalls += 1,
        onPauseRequested: () {},
      );
      handler.acquireOwnership(
        ownerId: 'mixer',
        onPlayRequested: () => mixerCalls += 1,
        onPauseRequested: () {},
      );

      await handler.play();
      handler.releaseOwnership(ownerId: 'player', token: playerToken);
      await handler.play();

      expect(playerCalls, equals(0));
      expect(mixerCalls, equals(2));
    },
    timeout: const Timeout(Duration(seconds: 5)),
  );

  test(
    'release transitions keep lock-screen callback ownership unambiguous',
    () async {
      final SleepAudioHandler handler = SleepAudioHandler();
      int mixerPauseCalls = 0;
      final int token = handler.acquireOwnership(
        ownerId: 'mixer',
        onPlayRequested: () {},
        onPauseRequested: () => mixerPauseCalls += 1,
      );

      handler.releaseOwnership(ownerId: 'mixer', token: token);
      await handler.pause();

      expect(handler.isOwnerActive('mixer', token), isFalse);
      expect(mixerPauseCalls, equals(0));
    },
    timeout: const Timeout(Duration(seconds: 5)),
  );
}
