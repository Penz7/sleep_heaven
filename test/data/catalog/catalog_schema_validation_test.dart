import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sleep_heaven/data/catalog/catalog_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('catalog schema validation', () {
    test('catalog json is schema-valid', () async {
      final String rawCatalog = await rootBundle.loadString(
        CatalogLoader.catalogAssetPath,
      );
      final String rawSchema = await rootBundle.loadString(
        CatalogLoader.schemaAssetPath,
      );

      final CatalogLoader loader = CatalogLoader();
      final CatalogLoadResult result = await loader.loadFromRaw(
        rawCatalog: rawCatalog,
        rawSchema: rawSchema,
      );

      expect(result.version, isNotEmpty);
      expect(result.sounds, isNotEmpty);
    });

    test('duplicate IDs fail validation guardrails', () async {
      final String rawSchema = await rootBundle.loadString(
        CatalogLoader.schemaAssetPath,
      );
      final Map<String, dynamic> catalog =
          jsonDecode(
                await rootBundle.loadString(CatalogLoader.catalogAssetPath),
              )
              as Map<String, dynamic>;

      final List<dynamic> sounds = catalog['sounds'] as List<dynamic>;
      final Map<String, dynamic> first = Map<String, dynamic>.from(
        sounds.first as Map<String, dynamic>,
      );
      sounds.add(first);

      final CatalogLoader loader = CatalogLoader();
      expect(
        () => loader.loadFromRaw(
          rawCatalog: jsonEncode(catalog),
          rawSchema: rawSchema,
        ),
        throwsFormatException,
      );
    });
  });
}
