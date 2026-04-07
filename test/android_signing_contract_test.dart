import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('release signing contract prefers env and fails with explicit message', () {
    final File gradleFile = File('android/app/build.gradle.kts');
    final String gradleContent = gradleFile.readAsStringSync();

    expect(gradleContent, contains('ANDROID_SIGNING_STORE_FILE'));
    expect(gradleContent, contains('ANDROID_SIGNING_STORE_PASSWORD'));
    expect(gradleContent, contains('ANDROID_SIGNING_KEY_ALIAS'));
    expect(gradleContent, contains('ANDROID_SIGNING_KEY_PASSWORD'));
    expect(gradleContent, contains('key.properties.local'));
    expect(gradleContent, contains('Missing required Android signing values'));
  });
}
