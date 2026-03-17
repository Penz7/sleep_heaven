/// Model nhạc local do user thêm từ thiết bị
class LocalTrackModel {
  const LocalTrackModel({
    required this.id,
    required this.title,
    required this.filePath,
  });

  final String id;
  final String title;
  final String filePath;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'filePath': filePath,
      };

  factory LocalTrackModel.fromJson(Map<String, dynamic> json) => LocalTrackModel(
        id: json['id'] as String,
        title: json['title'] as String,
        filePath: json['filePath'] as String,
      );
}
