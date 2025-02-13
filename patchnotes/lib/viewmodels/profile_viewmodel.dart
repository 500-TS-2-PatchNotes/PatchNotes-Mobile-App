import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileViewModel extends ChangeNotifier {
  String _profileImage = "";
  String _displayName = "Joshua Debele";
  String _email = "joshua@example.com";
  String _bio = "Software Engineer | Flutter Developer";
  bool _isEditingBio = false;
  String _deviceStatus = "Not Connected";
  String _woundStatus = "Current State: Healthy";
  String _medicalNotes = "Applied new dressing today.";
  bool _isEditingNotes = false;

  String get profileImage => _profileImage;
  String get displayName => _displayName;
  String get email => _email;
  String get bio => _bio;
  bool get isEditingBio => _isEditingBio;
  String get deviceStatus => _deviceStatus;
  String get woundStatus => _woundStatus;
  String get medicalNotes => _medicalNotes;
  bool get isEditingNotes => _isEditingNotes;

  void updateBio(String newBio) {
    _bio = newBio;
    notifyListeners();
  }

  void toggleBioEditing() {
    _isEditingBio = !_isEditingBio;
    notifyListeners();
  }

  void updateMedicalNotes(String newNotes) {
    _medicalNotes = newNotes;
    notifyListeners();
  }

  void toggleNotesEditing() {
    _isEditingNotes = !_isEditingNotes;
    notifyListeners();
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _profileImage = pickedFile.path;
      notifyListeners();
    }
  }
}
