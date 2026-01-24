import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:drawo_app/data/models/drawing_model.dart';

abstract class IGalleryService {
  Stream<List<DrawingModel>> imagesStream();
  Future<String> uploadImage({
    required Uint8List bytes,
    String? fileName,
    String? title,
    int? width,
    int? height,
  });
  Future<void> updateExistingImage({
    required String docId,
    required Uint8List bytes,
    required String oldStoragePath,
    String? title,
    int? width,
    int? height,
  });
  Future<void> deleteImage(String docId, String storagePath);
}

class GalleryService implements IGalleryService {
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

  CollectionReference<Map<String, dynamic>> get _userImagesCollection {
    if (_uid == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(_uid).collection('images');
  }

  // Upload a new image to Firebase Storage and Firestore
  @override
  Future<String> uploadImage({
    required Uint8List bytes,
    String? fileName,
    String? title,
    int? width,
    int? height,
  }) async {
    final name = fileName ?? 'img_${DateTime.now().millisecondsSinceEpoch}.png';
    final storagePath = 'users/$_uid/images/$name';

    final ref = _storage.ref(storagePath);
    final snapshot = await ref.putData(
      bytes,
      SettableMetadata(contentType: 'image/png'),
    );

    final url = await snapshot.ref.getDownloadURL();

    final doc = await _userImagesCollection.add({
      'url': url,
      'storagePath': storagePath,
      'title': _sanitizeTitle(title),
      'sizeBytes': bytes.length,
      'width': width,
      'height': height,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  // Replace an existing image with a new one
  @override
  Future<void> updateExistingImage({
    required String docId,
    required Uint8List bytes,
    required String oldStoragePath,
    String? title,
    int? width,
    int? height,
  }) async {
    // 1. Delete old image from storage
    await _storage.ref(oldStoragePath).delete();

    // 2. Upload new image
    final name = 'img_${DateTime.now().millisecondsSinceEpoch}_rev.png';
    final storagePath = 'users/$_uid/images/$name';

    final task = await _storage
        .ref(storagePath)
        .putData(bytes, SettableMetadata(contentType: 'image/png'));
    final url = await task.ref.getDownloadURL();

    // 3. Update existing document
    await _userImagesCollection.doc(docId).update({
      'url': url,
      'storagePath': storagePath,
      'title': _sanitizeTitle(title),
      'sizeBytes': bytes.length,
      'width': width,
      'height': height,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Stream of user's drawings from Firestore
  @override
  Stream<List<DrawingModel>> imagesStream() {
    if (_uid == null) return Stream.value([]);

    return _userImagesCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => DrawingModel.fromDoc(d)).toList());
  }

  // Delete drawing from Firebase Storage and Firestore document
  @override
  Future<void> deleteImage(String docId, String storagePath) async {
    await _storage.ref(storagePath).delete();
    await _userImagesCollection.doc(docId).delete();
  }

  String? _sanitizeTitle(String? title) {
    if (title == null || title.trim().isEmpty) return null;
    return title.trim();
  }
}
