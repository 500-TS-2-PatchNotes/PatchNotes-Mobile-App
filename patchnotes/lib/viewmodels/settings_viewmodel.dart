import 'package:flutter/material.dart';
import 'package:patchnotes/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class SettingsViewModel extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _areNotificationsEnabled = true;

  // Getters
  bool get isDarkMode => _isDarkMode;
  bool get areNotificationsEnabled => _areNotificationsEnabled;

  // Setters with NotifyListeners to update UI
  void toggleDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  void toggleNotifications(bool value) {
    _areNotificationsEnabled = value;
    notifyListeners();
  }

  void navigateToChangeEmail(BuildContext context) {
    // TODO: Implement navigation logic
  }

  void navigateToChangePassword(BuildContext context) {
    // TODO: Implement navigation logic
  }

  void pairNewDevice(BuildContext context) {
    // TODO: Implement pairing logic
  }

  void forgetDevice(BuildContext context) {
    // TODO: Implement forgetting device logic
  }

  void logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () {
              Provider.of<AuthViewModel>(context, listen: false).signOut(context);
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void deleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text("This action cannot be undone. Are you sure?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () {
              Provider.of<AuthViewModel>(context, listen: false).deleteAccount(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
