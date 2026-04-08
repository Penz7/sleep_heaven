import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/services/iap_service.dart';
import '../../../data/models/local_track_model.dart';
import '../../../data/repositories/local_track_repository.dart';
import '../../../routes/app_routes.dart';

/// Controller cho tính năng thêm nhạc từ thiết bị (premium only)
class LocalMusicController extends GetxController {
  LocalMusicController(this._repository, this._iapService);

  final LocalTrackRepository _repository;
  final IAPService _iapService;

  final RxList<LocalTrackModel> localTracks = <LocalTrackModel>[].obs;

  bool get isPremium => _iapService.isPremium.value;

  @override
  void onInit() {
    super.onInit();
    loadTracks();
  }

  Future<void> loadTracks() async {
    final list = await _repository.getAll();
    localTracks.assignAll(list);
  }

  /// Chọn file audio từ thiết bị và thêm vào danh sách
  Future<void> pickAndAddTrack() async {
    if (!isPremium) {
      Get.toNamed(Routes.premium);
      return;
    }

    final status = await _requestPermission();
    if (!status) {
      Get.snackbar('Permission', 'File access is required to add music.');
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'm4a', 'aac', 'wav', 'ogg', 'flac'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final path = file.path;
      if (path == null || path.isEmpty) {
        Get.snackbar('Error', 'Unable to read the selected file.');
        return;
      }

      final title = file.name;
      final id = 'local_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}';
      final track = LocalTrackModel(id: id, title: title, filePath: path);

      await _repository.add(track);
      localTracks.add(track);
    } catch (e) {
      debugPrint('[LocalMusicController] pickAndAddTrack error: $e');
      Get.snackbar('Error', 'Unable to add the file: $e');
    }
  }

  Future<bool> _requestPermission() async {
    if (!GetPlatform.isAndroid) return true;
    // Android 13+ (API 33): READ_MEDIA_AUDIO
    final audioStatus = await Permission.audio.request();
    if (audioStatus.isGranted) return true;
    // Android 12 trở xuống: READ_EXTERNAL_STORAGE
    final storageStatus = await Permission.storage.request();
    if (storageStatus.isGranted) return true;
    if (audioStatus.isPermanentlyDenied || storageStatus.isPermanentlyDenied) {
      await openAppSettings();
    }
    return false;
  }

  Future<void> removeTrack(String id) async {
    await _repository.remove(id);
    localTracks.removeWhere((t) => t.id == id);
  }
}
