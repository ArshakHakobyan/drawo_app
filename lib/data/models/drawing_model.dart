import 'package:cloud_firestore/cloud_firestore.dart';

class DrawingModel {
  final String id;
  final String url;
  final String storagePath;
  final String? title;
  final int? sizeBytes;
  final int? width;
  final int? height;
  final DateTime? createdAt;

  DrawingModel({
    required this.id,
    required this.url,
    required this.storagePath,
    this.title,
    this.sizeBytes,
    this.width,
    this.height,
    this.createdAt,
  });

  factory DrawingModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return DrawingModel(
      id: doc.id,
      url: d['url'] as String,
      storagePath: d['storagePath'] as String,
      title: d['title'] as String?,
      sizeBytes: (d['sizeBytes'] as num?)?.toInt(),
      width: (d['width'] as num?)?.toInt(),
      height: (d['height'] as num?)?.toInt(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
