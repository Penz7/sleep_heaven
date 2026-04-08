import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_heaven/data/catalog/catalog_loader.dart';
import 'package:sleep_heaven/data/models/sound_model.dart';

String _buildCatalogJson({required int count}) {
  final List<Map<String, Object>> sounds = List<Map<String, Object>>.generate(
    count,
    (int index) => <String, Object>{
      'id': 'sound_$index',
      'title': 'Sound $index',
      'categoryId': 'nature',
      'assetPath': 'assets/sounds/nature/sound_$index.mp3',
      'imagePath': 'assets/images/nature/sound_$index.png',
      'isPremium': index % 2 == 0,
      'icon': 'default',
    },
    growable: false,
  );
  return jsonEncode(<String, Object>{
    'version': 'v-growth',
    'sounds': sounds,
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('catalog growth loading', () {
    test('loader supports bounded startup decode window', () async {
      final CatalogLoader loader = CatalogLoader();
      final String rawSchema = await rootBundle.loadString(
        CatalogLoader.schemaAssetPath,
      );

      final CatalogLoadResult result = await loader.loadStartupSliceFromRaw(
        rawCatalog: _buildCatalogJson(count: 120),
        rawSchema: rawSchema,
        startupLimit: 12,
      );

      expect(result.sounds.length, equals(12));
      expect(result.version, equals('v-growth'));
    });

    test('fallback compatibility keeps typed sound models usable', () async {
      final CatalogLoader loader = CatalogLoader();
      final String rawSchema = await rootBundle.loadString(
        CatalogLoader.schemaAssetPath,
      );
      final CatalogLoadResult result = await loader.loadFromRaw(
        rawCatalog: _buildCatalogJson(count: 30),
        rawSchema: rawSchema,
      );

      expect(result.sounds, isA<List<SoundModel>>());
      expect(result.sounds.length, equals(30));
    });
  });
}
