import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:patchnotes/services/firestore_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  String _profileImage = "";
  String _displayName = "Joshua Debele";
  String _email = "joshua@example.com";
  String _bio = "Add a short bio about yourself";
  bool _isEditingBio = false;
  final String _deviceStatus = "Not Connected";
  String _woundStatus = "Current: Healthy";
  String _medicalNotes = "No medical notes added yet.";
  bool _isEditingNotes = false;

  // Getters
  String get profileImage => _profileImage;
  String get displayName => _displayName;
  String get email => _email;
  String get bio => _bio;
  bool get isEditingBio => _isEditingBio;
  String get deviceStatus => _deviceStatus;
  String get woundStatus => _woundStatus;
  String get medicalNotes => _medicalNotes;
  bool get isEditingNotes => _isEditingNotes;

  /// Constructor
  ProfileViewModel() {
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      // Fetch all required Firestore data asynchronously
      final userDataFuture = _firestoreService.getUser(userId);
      final accountDataFuture = _firestoreService.getAccountInfo(userId);
      final woundDataFuture = _firestoreService.getWound(userId);

      final userData = await userDataFuture;
      final accountData = await accountDataFuture;
      final woundData = await woundDataFuture;

      _profileImage = userData?.profilePic ?? "";
      _displayName = "${userData?.fName ?? ""} ${userData?.lName ?? ""}".trim();
      _email = userData?.email ?? "No email available";

      _bio = (accountData?.bio?.isNotEmpty ?? false)
          ? accountData!.bio!
          : "Add a short bio about yourself";
      _medicalNotes = (accountData?.medNote?.isNotEmpty ?? false)
          ? accountData!.medNote!
          : "No medical notes added yet.";

      _woundStatus = "Current: ${woundData?.woundStatus ?? 'Unknown'}";

      notifyListeners(); // Notify UI of updates
    } catch (e) {
      print("Error fetching profile data: $e");
    }
  }

  Future<void> fetchUserProfile(String uid) async {
  try {
    print("Fetching profile data for UID: $uid");
    notifyListeners();

    final userData = await _firestoreService.getUser(uid);
    final accountData = await _firestoreService.getAccountInfo(uid);
    final woundData = await _firestoreService.getWound(uid);

    if (userData != null) {
      _profileImage = userData.profilePic ?? ""; // Keep existing image if null
      _displayName = "${userData.fName} ${userData.lName}";
      _email = userData.email!;
    }

    _bio = (accountData?.bio?.isNotEmpty ?? false) ? accountData!.bio! : "";
    _medicalNotes = (accountData?.medNote?.isNotEmpty ?? false) ? accountData!.medNote! : "";
    _woundStatus = "Current: ${woundData?.woundStatus ?? 'Unknown'}";

    print("Updated Profile Data: $_displayName, Bio: $_bio, Notes: $_medicalNotes");

    notifyListeners();
  } catch (e) {
    print("Error fetching user profile: $e");
  }
}


  void updateBio(String newBio) {
    _bio = newBio.isNotEmpty ? newBio : "Add a short bio about yourself";
    notifyListeners();
  }

  void toggleBioEditing() {
    _isEditingBio = !_isEditingBio;
    notifyListeners();
  }

  void updateMedicalNotes(String newNotes) {
    _medicalNotes =
        newNotes.isNotEmpty ? newNotes : "No medical notes added yet.";
    notifyListeners();
  }

  void toggleNotesEditing() {
    _isEditingNotes = !_isEditingNotes;
    notifyListeners();
  }

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _profileImage = pickedFile.path;
      notifyListeners();
    }
  }

  void reset() {
  _profileImage = "";
  _displayName = "";
  _email = "";
  _bio = "";
  _medicalNotes = "";
  _woundStatus = "";
  _isEditingBio = false;
  _isEditingNotes = false;
  notifyListeners();
}

}
