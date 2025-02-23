import 'package:firebase_auth/firebase_auth.dart';
import 'package:patchnotes/models/collections/user.dart';

class AuthState {
  final User? firebaseUser; 
  final AppUser? appUser;  
  final bool isLoading;
  final String? errorMessage;

  AuthState({
    this.firebaseUser,
    this.appUser,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    User? firebaseUser,
    AppUser? appUser,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      firebaseUser: firebaseUser ?? this.firebaseUser,
      appUser: appUser ?? this.appUser,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
