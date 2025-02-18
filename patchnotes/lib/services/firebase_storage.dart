import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload Profile Picture & Return Download URL
  Future<String?> uploadProfilePicture(String uid, Uint8List imageBytes) async {
    try {
      String filePath = 'profile_pictures/$uid/profile.jpg';

      Reference ref = _storage.ref().child(filePath);
      UploadTask uploadTask = ref.putData(imageBytes);
      TaskSnapshot snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading profile picture: $e');
      return null;
    }
  }

  // Delete Profile Picture
  Future<void> deleteProfilePicture(String uid) async {
    try {
      String filePath = 'profile_pictures/$uid/profile.jpg';
      await _storage.ref().child(filePath).delete();
    } catch (e) {
      print('Error deleting profile picture: $e');
    }
  }

  // Upload Wound Image & Return Download URL
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

  // Delete Specific Wound Image
  Future<void> deleteWoundImage(String woundId, String imageUrl) async {
    try {
      Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting wound image: $e');
    }
  }

  // Delete All Wound Images for a Specific Wound
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
