import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:json_schema/json_schema.dart';

import '../models/sound_model.dart';

class CatalogLoader {
  static const String catalogAssetPath = 'assets/catalog/sound_catalog.v1.json';
  static const String schemaAssetPath = 'assets/catalog/sound_catalog.schema.json';

  Future<CatalogLoadResult> loadFromAssets({
    String catalogPath = catalogAssetPath,
    String schemaPath = schemaAssetPath,
  }) async {
    final String rawCatalog = await rootBundle.loadString(catalogPath);
    final String rawSchema = await rootBundle.loadString(schemaPath);
    return loadFromRaw(rawCatalog: rawCatalog, rawSchema: rawSchema);
  }

  Future<CatalogLoadResult> loadFromRaw({
    required String rawCatalog,
    required String rawSchema,
  }) async {
    final Map<String, dynamic> catalogJson =
        jsonDecode(rawCatalog) as Map<String, dynamic>;
    final Map<String, dynamic> schemaJson =
        jsonDecode(rawSchema) as Map<String, dynamic>;

    final JsonSchema schema = await JsonSchema.createAsync(schemaJson);
    final ValidationResults validation = schema.validate(catalogJson);
    if (!validation.isValid) {
      throw FormatException(
        'Catalog schema validation failed: ${validation.errors.join(', ')}',
      );
    }

    final String version = catalogJson['version'] as String;
    final List<dynamic> sounds = catalogJson['sounds'] as List<dynamic>;
    final List<SoundModel> decoded = sounds
        .map((dynamic item) => SoundModel.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);

    _assertUniqueIds(decoded);
    return CatalogLoadResult(version: version, sounds: decoded);
  }

  void _assertUniqueIds(List<SoundModel> sounds) {
    final Set<String> ids = <String>{};
    for (final SoundModel sound in sounds) {
      if (!ids.add(sound.id)) {
        throw FormatException('Duplicate sound id found: ${sound.id}');
      }
    }
  }
}

class CatalogLoadResult {
  const CatalogLoadResult({
    required this.version,
    required this.sounds,
  });

  final String version;
  final List<SoundModel> sounds;
}
