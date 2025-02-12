import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

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
}
