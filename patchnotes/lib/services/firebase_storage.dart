import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadProfilePicture(String uid, Uint8List imageBytes) async {
    try {
      String filePath = 'profile_pictures/$uid/profile.jpg';
      Reference ref = _storage.ref().child(filePath);

      try {
        await ref.delete();
        print("Old profile picture deleted.");
      } catch (e) {
        print("No previous profile picture found or error deleting it: $e");
      }

      // Upload new profile picture
      UploadTask uploadTask = ref.putData(imageBytes);
      TaskSnapshot snapshot = await uploadTask;

      // Return new download URL
      return await snapshot.ref.getDownloadURL(); 
    } catch (e) {
      print('Error uploading profile picture: $e');
      return null;
    }
  }

  Future<void> deleteProfilePicture(String uid) async {
    try {
      String filePath = 'profile_pictures/$uid/profile.jpg';
      await _storage.ref().child(filePath).delete();
      print("Profile picture deleted successfully on logout.");
    } catch (e) {
      print('Error deleting profile picture: $e');
    }
  }

  Future<String?> uploadWoundImage(String woundId, Uint8List imageBytes) async {
    try {
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String filePath = 'wound_images/$woundId/$timestamp.jpg';

      Reference ref = _storage.ref().child(filePath);
      UploadTask uploadTask = ref.putData(imageBytes);
      TaskSnapshot snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading wound image: $e');
      return null;
    }
  }

  Future<void> deleteWoundImage(String imageUrl) async {
    try {
      Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting wound image: $e');
    }
  }

  Future<void> deleteAllWoundImages(String woundId) async {
    try {
      ListResult result =
          await _storage.ref().child('wound_images/$woundId').listAll();

      for (Reference fileRef in result.items) {
        await fileRef.delete();
      }
    } catch (e) {
      print('Error deleting all wound images: $e');
    }
  }
}
