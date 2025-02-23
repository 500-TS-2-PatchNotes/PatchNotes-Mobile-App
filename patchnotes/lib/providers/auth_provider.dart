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

  // If already logged in at startup, trigger user data load.
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
    Future(() async {
      await _checkUserSession();
    });
  }

  Future<void> _checkUserSession() async {
    final user = _auth.currentUser;
    if (user != null) {
      state = state.copyWith(firebaseUser: user);
      // The userProvider listener will load user data.
    }
  }

  Future<void> login(String email, String password) async {
  state = state.copyWith(isLoading: true);
  try {
    final user = await _authService.signIn(email, password);
    if (user != null) {
      state = state.copyWith(firebaseUser: user);
      // Explicitly load user data after login.
      await _ref.read(userProvider.notifier).loadUserData();
      state = state.copyWith(isLoading: false);
    } else {
      state = state.copyWith(isLoading: false);
    }
  } catch (e) {
    state = state.copyWith(errorMessage: "Login failed: $e", isLoading: false);
  }
}


  Future<void> register(String email, String password, String fName, String lName) async {
  state = state.copyWith(isLoading: true);
  try {
    final userCredential = await _authService.register(email, password);
    final user = userCredential.user;
    if (user != null) {
      await _ref.read(userProvider.notifier)
          .initializeNewUser(user.uid, fName, lName, email);
      state = state.copyWith(firebaseUser: user, isLoading: false);
    } else {
      state = state.copyWith(isLoading: false);
    }
  } catch (e) {
    state = state.copyWith(errorMessage: "Registration failed: $e", isLoading: false);
  }
}


  Future<void> logout() async {
    print("Logging out...");
    await _authService.signOut();

    // Reset user data
    _ref.read(userProvider.notifier).resetUserData();

    // Reset auth state
    state = AuthState();

    // Navigate to login screen after reset
    Future.microtask(() {
      final navigatorKey = _ref.read(navigatorKeyProvider);
      navigatorKey.currentState
          ?.pushNamedAndRemoveUntil("/login", (route) => false);
    });

    print("Logout completed, navigating to login");
  }

  Future<void> reauthenticateAndDelete(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final user = _auth.currentUser;
      if (user == null) {
        state = state.copyWith(
            errorMessage: "No user is currently logged in", isLoading: false);
        return;
      }

      // Reauthenticate the user before deleting the account.
      await _authService.reauthenticateAndDelete(email, password);

      // Delete user data from Firestore.
      await _deleteUserData(user.uid);

      // Reset auth and user states.
      _ref.read(userProvider.notifier).resetUserData();
      state = AuthState();
    } catch (e) {
      state = state.copyWith(
          errorMessage: "Account deletion failed: $e", isLoading: false);
    }
  }

  /// Delete user-related data from Firestore.
  Future<void> _deleteUserData(String uid) async {
    try {
      final firestore = _ref.read(firestoreServiceProvider);
      await Future.wait([
        firestore.userCollection.doc(uid).delete(),
        firestore.accountCollection.doc(uid).delete(),
        firestore.woundCollection.doc(uid).delete(),
      ]);
      print("User data deleted from Firestore");

      // Only reset the user provider's state.
      _ref.read(userProvider.notifier).resetUserData();
      // Removed _ref.invalidate calls to avoid circular dependency.
    } catch (e) {
      print("⚠️ Error deleting user data: $e");
    }
  }
}
