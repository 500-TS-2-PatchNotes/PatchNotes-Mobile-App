import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:patchnotes/viewmodels/dashboard_viewmodel.dart';
import 'package:patchnotes/viewmodels/profile_viewmodel.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/collections/user.dart';
import '../models/collections/account.dart';
import '../models/collections/wound.dart';
import 'settings_viewmodel.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  AuthViewModel(this._authService, this._firestoreService);

  User? _firebaseUser;
  AppUser? _appUser;
  Account? _account;
  Wound? _wound;
  StreamSubscription<User?>? _authSubscription;

  bool _isLoading = false;
  String? errorMessage;

  // Getter Functions
  User? get firebaseUser => _firebaseUser;
  AppUser? get appUser => _appUser;
  Account? get account => _account;
  Wound? get wound => _wound;
  bool get isLoading => _isLoading;

  // Listen for Firebase Auth Changes
  void listenToAuthChanges() {
    _authSubscription?.cancel();
    _authSubscription = _authService.authStateChanges.listen((user) async {
      if (_firebaseUser == user) return;
      _firebaseUser = user;

      if (user != null) {
        await fetchAllUserData(user.uid);
      } else {
        clearUserData();
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  // Fetches User, Account, and Wound Data
  Future<void> fetchAllUserData(String uid) async {
    try {
      _isLoading = true;
      notifyListeners();

      final results = await Future.wait([
        _firestoreService.getUser(uid),
        _firestoreService.getAccountInfo(uid),
        _firestoreService.getWound(uid),
      ]);

      _appUser = results[0] as AppUser?;
      _account = results[1] as Account?;
      _wound = results[2] as Wound?;
    } catch (e) {
      errorMessage = "Error fetching user data: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Authentication related methods
  Future<bool> login(
      String email, String password, BuildContext context) async {
    try {
      _isLoading = true;
      errorMessage = null;
      notifyListeners();

      var user = await _authService.signIn(email, password);
      if (user != null) {
        _firebaseUser = user;

        // Reset previous user's cached data
        Provider.of<ProfileViewModel>(context, listen: false).reset();
        Provider.of<SettingsViewModel>(context, listen: false).reset();
        Provider.of<BacterialGrowthViewModel>(context, listen: false).reset();

        // Fetch new user's data
        await Future.wait([
          fetchAllUserData(user.uid),
          Provider.of<SettingsViewModel>(context, listen: false)
              .loadSettings(user.uid),
          Provider.of<ProfileViewModel>(context, listen: false)
              .fetchUserProfile(user.uid),
          Provider.of<BacterialGrowthViewModel>(context, listen: false)
              .fetchDashboardData(user.uid),
        ]);

        return true;
      }
    } catch (error) {
      errorMessage = "Login failed: $error";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<bool> register(
      String email, String password, String fName, String lName) async {
    try {
      _isLoading = true;
      errorMessage = null;
      notifyListeners();

      UserCredential userCredential =
          await _authService.register(email, password);
      User? user = userCredential.user;

      if (user == null) {
        errorMessage = "Registration failed: No user returned.";
        return false;
      }

      _firebaseUser = user;
      String uid = user.uid;

      _appUser =
          AppUser(email: email, fName: fName, lName: lName, profilePic: "");
      _account = Account(
        bio: "",
        woundStatus: "",
        medNote: "",
        darkMode: false,
        enabledNotifications: true,
        dateCreated: Timestamp.now(),
      );
      _wound = Wound(
        woundStatus: "",
        woundImages: [],
        imageTimestamp: Timestamp.now(),
        lastSynced: Timestamp.now(),
        colour: "",
        cfu: 0.0,
      );

      try {
        print("Writing user data to Firestore for UID: $uid");
        await _firestoreService.setUserData(uid, _appUser!, _account!, _wound!);
        print("Firestore data write successful for UID: $uid");
      } catch (e) {
        print("Firestore write failed: $e");
        errorMessage = "Failed to save user data.";
        return false;
      }

      // Fetches user data
      await fetchAllUserData(uid);

      return true; // Registration successful
    } catch (error) {
      print("Registration error: $error");
      errorMessage = "Registration failed: $error";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout Function
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      clearUserData();
      notifyListeners();
    } catch (e) {
      errorMessage = "Error during sign-out: $e";
      notifyListeners();
    }
  }

  // Delete Account with Fixes
  Future<void> deleteAccount(String email, String password) async {
    try {
      await _authService.reauthenticateAndDelete(email, password);
      if (_firebaseUser != null) {
        await _firestoreService.deleteAllUserData(_firebaseUser!.uid);
      }

      clearUserData();
      notifyListeners();
    } catch (e) {
      errorMessage = "Error deleting account: $e";
      notifyListeners();
    }
  }

  // Clears the Local User Data
  void clearUserData() {
    _firebaseUser = null;
    _appUser = null;
    _account = null;
    _wound = null;
    errorMessage = null;
    notifyListeners();
  }
}
