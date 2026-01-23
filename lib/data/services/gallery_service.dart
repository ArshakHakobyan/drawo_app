import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:drawo_app/data/models/drawing_model.dart';

class GalleryService {
  GalleryService({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _storage = storage,
       _auth = auth;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  String? get _uid => _auth.currentUser?.uid;

  Future<String> uploadImage({
    required Uint8List bytes,
    String? fileName,
    String? title,
    int? width,
    int? height,
  }) async {
    if (_uid == null) throw Exception('User not authenticated');

    final name = fileName ?? 'img_${DateTime.now().millisecondsSinceEpoch}.png';
    final storagePath = 'users/$_uid/images/$name';

    final task = await _storage
        .ref(storagePath)
        .putData(bytes, SettableMetadata(contentType: 'image/png'));
    final url = await task.ref.getDownloadURL();

    final doc = await _firestore
        .collection('users')
        .doc(_uid)
        .collection('images')
        .add({
          'url': url,
          'storagePath': storagePath,
          'title': (title?.trim().isEmpty ?? true) ? null : title,
          'sizeBytes': bytes.length,
          'width': width,
          'height': height,
          'createdAt': FieldValue.serverTimestamp(),
        });

    return doc.id;
  }

  Stream<List<DrawingModel>> imagesStream() {
    if (_uid == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('images')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => DrawingModel.fromDoc(d)).toList());
  }

  Future<void> deleteImage(String docId, String storagePath) async {
    if (_uid == null) throw Exception('User not authenticated');

    await _storage.ref(storagePath).delete();
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('images')
        .doc(docId)
        .delete();
  }
}
