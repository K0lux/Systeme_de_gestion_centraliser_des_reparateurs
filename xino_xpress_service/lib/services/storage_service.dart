import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile(File file, String path) async {
    try {
      TaskSnapshot snapshot = await _storage.ref(path).putFile(file);
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Erreur lors du téléchargement du fichier: $e');
      rethrow;
    }
  }

  Future<void> deleteFile(String path) async {
    try {
      await _storage.ref(path).delete();
    } catch (e) {
      print('Erreur lors de la suppression du fichier: $e');
      rethrow;
    }
  }
}
