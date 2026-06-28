import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile({
    required String path,
    required String fileName,
  }) async {
    final ref = _storage.ref().child(path).child(fileName);
    final uploadTask = ref.putString('');
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<String> getDownloadURL(String path) async {
    final ref = _storage.ref().child(path);
    return await ref.getDownloadURL();
  }

  Future<void> deleteFile(String path) async {
    final ref = _storage.ref().child(path);
    await ref.delete();
  }
}
