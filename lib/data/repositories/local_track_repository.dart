import '../models/local_track_model.dart';
import '../providers/local_track_provider.dart';

/// Repository quản lý local tracks – CRUD
class LocalTrackRepository {
  LocalTrackRepository(this._provider);

  final LocalTrackProvider _provider;

  Future<List<LocalTrackModel>> getAll() => _provider.getAll();

  Future<void> add(LocalTrackModel track) => _provider.add(track);

  Future<void> remove(String id) => _provider.remove(id);
}
