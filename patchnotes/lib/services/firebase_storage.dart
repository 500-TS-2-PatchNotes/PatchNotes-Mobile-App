import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads a user's profile picture and replaces the old one if it exists.
  Future<String?> uploadProfilePicture(String uid, Uint8List imageBytes) async {
    try {
      final filePath = 'profile_pictures/$uid/profile.jpg';
      final ref = _storage.ref().child(filePath);

      try {
        await ref.delete(); // Delete old profile pic if present
        print("Old profile picture deleted.");
      } catch (e) {
        print("No previous profile picture found: $e");
      }

      final metadata = SettableMetadata(contentType: 'image/jpeg');
      final snapshot = await ref.putData(imageBytes, metadata);

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading profile picture: $e');
      return null;
    }
  }

  /// Deletes the profile picture for a user.
  Future<void> deleteProfilePicture(String uid) async {
    try {
      final filePath = 'profile_pictures/$uid/profile.jpg';
      await _storage.ref().child(filePath).delete();
      print("Profile picture deleted successfully.");
    } catch (e) {
      print('Error deleting profile picture: $e');
    }
  }

  /// Uploads a wound image for a user and returns its public URL.
  Future<String?> uploadWoundImage(String uid, Uint8List imageBytes) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final filePath = 'images/$uid/$timestamp.jpg';
      final ref = _storage.ref().child(filePath);

      final metadata = SettableMetadata(contentType: 'image/jpeg');
      final snapshot = await ref.putData(imageBytes, metadata);

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading wound image: $e');
      return null;
    }
  }

  /// Deletes a specific wound image using its download URL.
  Future<void> deleteWoundImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting wound image: $e');
    }
  }

  /// Deletes all wound images for a user.
  Future<void> deleteAllWoundImages(String uid) async {
    try {
      final result = await _storage.ref().child('images/$uid').listAll();
      for (final fileRef in result.items) {
        await fileRef.delete();
      }
    } catch (e) {
      print('Error deleting all wound images: $e');
    }
  }

  /// Returns the 9 most recent wound image URLs for a user.
  Future<List<String>> listWoundImageUrls(String uid) async {
    try {
      final result = await _storage.ref('images/$uid').listAll();

      final sortedItems = result.items..sort((a, b) => b.name.compareTo(a.name));
      final limitedItems = sortedItems.take(9);

      final urls = await Future.wait(
        limitedItems.map((ref) => ref.getDownloadURL()),
      );

      return urls;
    } catch (e) {
      print('Error listing wound images: $e');
      return [];
    }
  }
}
