import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:patchnotes/providers/navigation.dart';
import 'package:patchnotes/states/auth_state.dart';
import 'package:patchnotes/providers/user_provider.dart';
import '../services/auth_service.dart';

// Firebase Auth Provider
final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Auth State Notifier
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authNotifier = AuthNotifier(
    ref.read(authServiceProvider),
    ref.read(firebaseAuthProvider),
    ref,
  );

  // Check user session on startup
  Future(() async {
    if (authNotifier.state.firebaseUser != null) {
      await ref.read(userProvider.notifier).loadUserData();
    }
  });

  return authNotifier;
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final FirebaseAuth _auth;
  final Ref _ref;

  AuthNotifier(this._authService, this._auth, this._ref) : super(AuthState()) {
    _checkUserSession();
  }

  Future<void> _checkUserSession() async {
    state = state.copyWith(firebaseUser: _auth.currentUser);
  }

  Future<void> login(String email, String password) async {
    await _handleAuthOperation(() async {
      final user = await _authService.signIn(email, password);
      if (user != null) {
        state = state.copyWith(firebaseUser: user);
        await _ref.read(userProvider.notifier).loadUserData();
      }
    }, "Login failed");
  }

  Future<void> register(
      String email, String password, String fName, String lName) async {
    await _handleAuthOperation(() async {
      final userCredential = await _authService.register(email, password);
      final user = userCredential.user;
      if (user != null) {
        await _ref
            .read(userProvider.notifier)
            .initializeNewUser(user.uid, fName, lName, email);
        state = state.copyWith(firebaseUser: user);
      }
    }, "Registration failed");
  }

  Future<void> logout() async {
    await _authService.signOut();
    _ref.read(userProvider.notifier).resetUserData();
    state = AuthState();

    // Navigate to login screen
    Future.microtask(() {
      _ref
          .read(navigatorKeyProvider)
          .currentState
          ?.pushNamedAndRemoveUntil("/login", (route) => false);
    });
  }

  Future<void> reauthenticateUser(String password) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
          code: 'user-not-found', message: 'No user found.');
    }

    AuthCredential credential =
        EmailAuthProvider.credential(email: user.email!, password: password);
    await user.reauthenticateWithCredential(credential);
  }

  Future<void> reauthenticateAndDelete(String email, String password) async {
    await _handleAuthOperation(() async {
      final user = _auth.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
            code: 'user-not-found', message: 'No user found.');
      }

      await _authService.reauthenticateAndDelete(email, password);
      await _deleteUserData(user.uid);

      _ref.read(userProvider.notifier).resetUserData();
      state = AuthState();
    }, "Account deletion failed");
  }

  Future<void> _deleteUserData(String uid) async {
    try {
      final firestore = _ref.read(firestoreServiceProvider);
      await Future.wait([
        firestore.userCollection.doc(uid).delete(),
        firestore.accountCollection.doc(uid).delete(),
        firestore.woundCollection.doc(uid).delete(),
      ]);
    } catch (e) {
      print("Error deleting user data: $e");
    }
  }

  Future<void> forgotPassword(String email) async {
    await _handleAuthOperation(() async {
      await _auth.sendPasswordResetEmail(email: email);
      state =
          state.copyWith(successMessage: "Password reset email sent to $email");
    }, "Failed to send password reset email");
  }

  Future<void> updateEmail(String newEmail) async {
  await _handleAuthOperation(() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.verifyBeforeUpdateEmail(newEmail);

      await _ref.read(userProvider.notifier).updateUserEmail(user.uid, newEmail);

      await _ref.read(userProvider.notifier).loadUserData();
    }
  }, "Failed to update email");
}



  Future<void> updatePassword(String newPassword) async {
    await _handleAuthOperation(() async {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      }
    }, "Failed to update password");
  }

  Future<void> _handleAuthOperation(
      Future<void> Function() operation, String errorMessage) async {
    state = state.copyWith(isLoading: true);
    try {
      await operation();
    } catch (e) {
      state = state.copyWith(errorMessage: "$errorMessage: $e");
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: "", isLoading: false);
  }
}
