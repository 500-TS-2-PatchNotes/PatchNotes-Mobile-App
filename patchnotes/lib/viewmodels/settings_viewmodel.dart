import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:patchnotes/viewmodels/dashboard_viewmodel.dart';
import 'package:patchnotes/viewmodels/profile_viewmodel.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../services/firestore_service.dart';
import '../models/collections/account.dart';

class SettingsViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController passwordController = TextEditingController();

  // Default Settings for the App
  bool _isDarkMode = false;
  bool _areNotificationsEnabled = true;
  bool _isLoading = false;
  bool _isLoaded = false;
  String? errorMessage;

  bool get isDarkMode => _isDarkMode;
  bool get areNotificationsEnabled => _areNotificationsEnabled;
  bool get isLoading => _isLoading;
  bool get isLoaded => _isLoaded;

  /// Constructor - Automatically Fetches Settings
  SettingsViewModel() {
    _initializeSettings();
  }

  /// Fetch settings from Firestore on initialization
  Future<void> _initializeSettings() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    await loadSettings(userId);
  }

  /// Load settings from Firestore
  Future<void> loadSettings(String uid) async {
    if (_isLoaded) return; // Prevent re-fetching if already loaded

    _isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      Account? account = await _firestoreService.getAccountInfo(uid);
      if (account != null) {
        _isDarkMode = account.darkMode ?? false;
        _areNotificationsEnabled = account.enabledNotifications ?? true;
      }

      _isLoaded = true;
    } catch (e) {
      errorMessage = "Error loading settings: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleDarkMode(String uid, bool value) async {
    try {
      await _firestoreService.updateAccount(uid, {"darkMode": value});
      _isDarkMode = value;
      notifyListeners();
    } catch (e) {
      errorMessage = "Failed to update Dark Mode: $e";
      notifyListeners();
    }
  }

  Future<void> toggleNotifications(String uid, bool value) async {
    try {
      await _firestoreService
          .updateAccount(uid, {"enabledNotifications": value});
      _areNotificationsEnabled = value;
      notifyListeners();
    } catch (e) {
      errorMessage = "Failed to update Notifications: $e";
      notifyListeners();
    }
  }

  void navigateToChangeEmail(BuildContext context) {
    Navigator.pushNamed(context, '/change-email');
  }

  void navigateToChangePassword(BuildContext context) {
    Navigator.pushNamed(context, '/change-password');
  }

  void pairNewDevice(BuildContext context) {
    // TODO: Implement pairing logic
  }

  void forgetDevice(BuildContext context) {
    // TODO: Implement forgetting device logic
  }

  /// Logout Confirmation Dialog
  void logout(BuildContext context) async {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final profileVM = Provider.of<ProfileViewModel>(context, listen: false);
    final dashboardVM =
        Provider.of<BacterialGrowthViewModel>(context, listen: false);

    try {
      String? userId = authVM.firebaseUser?.uid;
      if (userId == null) return;

      print("Saving user changes before logout...");
      await saveUserChanges(userId, profileVM, dashboardVM);
      print("Signing out...");
      await authVM.signOut();
      print("User signed out successfully.");


      resetUserData(context);

      Future.delayed(Duration(milliseconds: 500), () {
        if (context.mounted) {
          print("Navigating to /login...");
          Navigator.pushNamedAndRemoveUntil(
              context, '/login', (route) => false);
        } else {
          print("The context is not mounted");
        }
      });
    } catch (e) {
      print("Error during logout: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Logout failed: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Delete Account Confirmation Dialog
  Future<void> deleteAccount(
      BuildContext context, String email, String password) async {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);

    try {
      String? userId = authVM.firebaseUser?.uid;
      if (userId == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("User not found. Please log in again."),
                backgroundColor: Colors.red),
          );
        }
        return;
      }

      // Delete user data from Firestore
      await _firestoreService.deleteAllUserData(userId);

      // Delete the Firebase user
      await authVM.deleteAccount(email, password);

      // Ensure the user is fully signed out
      await FirebaseAuth.instance.signOut();

      // Clear local data in `AuthViewModel`
      authVM.clearUserData();

      // Wait before navigation to allow UI rebuild
      Future.delayed(Duration(milliseconds: 500), () {
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
              context, '/login', (route) => false);
        }
      });
    } catch (e) {
      print("Error deleting account: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Failed to delete account: $e"),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  // Saves the Changes User makes after they log out.
  Future<void> saveUserChanges(String uid, ProfileViewModel profileVM,
      BacterialGrowthViewModel dashboardVM) async {
    try {
      // Prepare updates for User collection
      Map<String, dynamic> updatedUserData = {};
      if (profileVM.profileImage.isNotEmpty) {
        updatedUserData["profilePic"] = profileVM.profileImage;
      }
      if (profileVM.displayName.isNotEmpty) {
        updatedUserData["name"] = profileVM.displayName;
      }
      if (profileVM.email.isNotEmpty) {
        updatedUserData["email"] = profileVM.email;
      }

      // Update Firestore User document only if there are changes
      if (updatedUserData.isNotEmpty) {
        await _firestoreService.updateUser(uid, updatedUserData);
      }

      // Prepare updates for Account collection
      Map<String, dynamic> updatedAccountData = {
        "bio": profileVM.bio,
        "woundStatus": dashboardVM.currentState, // Latest wound status
        "medicalNote": profileVM.medicalNotes,
        "darkMode": _isDarkMode, // Already updated in Firestore when toggled
        "enabledNotifications":
            _areNotificationsEnabled, // Already updated in Firestore when toggled
      };

      await _firestoreService.updateAccount(uid, updatedAccountData);

      // Prepare updates for Wound collection
      Map<String, dynamic> updatedWoundData = {
        "woundStatus": dashboardVM.currentState,
        "colour": dashboardVM.woundStateColor,
        "cfu": dashboardVM.cfu,
        "lastSynced": DateTime.now().toIso8601String(),
      };

      await _firestoreService.updateWound(uid, updatedWoundData);
      print(
          "User, account, and wound data successfully updated before logout.");
    } catch (e) {
      print("Error updating user data before logout: $e");
    }
  }

  void reset() {
  _isDarkMode = false;
  _areNotificationsEnabled = true;
  _isLoading = false;
  _isLoaded = false;
  errorMessage = null;
  notifyListeners();
}


  void resetUserData(BuildContext context) {
  final authVM = Provider.of<AuthViewModel>(context, listen: false);
  final settingsVM = Provider.of<SettingsViewModel>(context, listen: false);
  final profileVM = Provider.of<ProfileViewModel>(context, listen: false);
  final dashboardVM = Provider.of<BacterialGrowthViewModel>(context, listen: false);

  print("🔄 Resetting user data...");
    authVM.clearUserData();
    settingsVM.reset();
    profileVM.reset();
    dashboardVM.reset();

  print("Reset Complete.");
}


  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }
}
