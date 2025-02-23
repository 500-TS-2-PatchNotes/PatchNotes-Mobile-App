import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw e.code;
    }
  }

  Future<UserCredential> register(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw "Error signing out: $e";
    }
  }

  Future<void> deleteUser() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.delete();
      } else {
        throw "No user signed in.";
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "requires-recent-login") {
        throw "Please log in again before deleting your account.";
      } else {
        throw "Error deleting account: ${e.code}";
      }
    }
  }

  // Handles Re-authentication Before Deleting User
  Future<void> reauthenticateAndDelete(String email, String password) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw "No user signed in.";

      AuthCredential credential = EmailAuthProvider.credential(
        email: email.trim(),
        password: password.trim(),
      );

      await user.reauthenticateWithCredential(credential);
      await user.delete();
    } catch (e) {
      throw "Error re-authenticating: $e";
    }
  }

  // This is a getter function that returns the current user
  User? get currentUser => _auth.currentUser;

}


