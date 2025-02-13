import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? get user => _authService.currentUser;

  bool isLoading = false;
  String? errorMessage;

  Future<bool> login(String email, String password) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      var user = await _authService.signIn(email, password);

      isLoading = false;
      notifyListeners();

      return user != null;
    } catch (error) {
      isLoading = false;
      errorMessage = error.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      var user = await _authService.register(email, password);

      isLoading = false;
      notifyListeners();

      return user != null;
    } catch (error) {
      isLoading = false;
      errorMessage = error.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut(BuildContext context) async {
    await _authService.signOut();
    notifyListeners();

    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Future<void> deleteAccount(BuildContext context) async {
    try {
      await _authService.deleteUser();
      await signOut(context);
    } catch (e) {
      print("Error deleting account: $e");

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete account: $e")),
        );
        Navigator.pop(context);
      }
    }
  }
}
