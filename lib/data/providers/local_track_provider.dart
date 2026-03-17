import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/local_track_model.dart';

/// Provider lưu danh sách local tracks vào secure storage (JSON array)
class LocalTrackProvider {
  static const String _storageKey = 'local_tracks';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Đọc danh sách tracks từ storage
  Future<List<LocalTrackModel>> getAll() async {
    try {
      final raw = await _storage.read(key: _storageKey);
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => LocalTrackModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[LocalTrackProvider] getAll error: $e');
      return [];
    }
  }

  /// Ghi danh sách tracks vào storage
  Future<void> saveAll(List<LocalTrackModel> tracks) async {
    final list = tracks.map((e) => e.toJson()).toList();
    await _storage.write(key: _storageKey, value: jsonEncode(list));
  }

  /// Thêm một track
  Future<void> add(LocalTrackModel track) async {
    final current = await getAll();
    if (current.any((t) => t.id == track.id)) return;
    current.add(track);
    await saveAll(current);
  }

  /// Xóa track theo id
  Future<void> remove(String id) async {
    final current = await getAll();
    current.removeWhere((t) => t.id == id);
    await saveAll(current);
  }
}
