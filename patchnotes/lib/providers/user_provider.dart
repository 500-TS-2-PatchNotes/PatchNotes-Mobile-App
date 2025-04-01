import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:patchnotes/providers/auth_provider.dart';
import 'package:patchnotes/states/user_state.dart';
import '../services/firestore_service.dart';
import '../services/firebase_storage.dart';
import '../models/collections/user.dart';
import '../models/collections/account.dart';
import '../models/collections/wound.dart';

// Firestore & Storage Providers
final firestoreServiceProvider =
    Provider<FirestoreService>((ref) => FirestoreService());
final firebaseStorageServiceProvider =
    Provider<FirebaseStorageService>((ref) => FirebaseStorageService());

// StreamProvider for Authentication Changes
final authStateProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
});

// User Provider
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  final firestoreService = ref.read(firestoreServiceProvider);
  final storageService = ref.read(firebaseStorageServiceProvider);
  final notifier = UserNotifier(ref, firestoreService, storageService);

  // Listen to auth state changes.
  ref.listen<AsyncValue<User?>>(authStateProvider, (previous, next) {
    notifier.handleAuthStateChanged(next.value);
  });

  return notifier;
});

class UserNotifier extends StateNotifier<UserState> {
  final Ref ref;
  final FirestoreService _firestoreService;
  final FirebaseStorageService _storageService;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _accountSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _woundSubscription;

  UserNotifier(this.ref, this._firestoreService, this._storageService)
      : super(UserState());

  void handleAuthStateChanged(User? user) {
    if (user == null) {
      resetUserData();
    } else {
      _listenToUserChanges(user.uid);
    }
  }

  void _listenToUserChanges(String uid) {
    _cancelSubscriptions();
    state = state.copyWith(uid: uid);

    _userSubscription = _firestoreService
        .getUserDoc(uid)
        .withConverter<Map<String, dynamic>>(
          fromFirestore: (snapshot, _) => snapshot.data()!,
          toFirestore: (data, _) => data,
        )
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        state = state.copyWith(appUser: AppUser.fromMap(snapshot.data()!));
      }
    }, onError: (error) {
      state = state.copyWith(errorMessage: "User data stream error: $error");
    });

    _accountSubscription = _firestoreService
        .getAccountDoc(uid)
        .withConverter<Map<String, dynamic>>(
          fromFirestore: (snapshot, _) => snapshot.data()!,
          toFirestore: (data, _) => data,
        )
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        state = state.copyWith(account: Account.fromMap(snapshot.data()!));
      }
    }, onError: (error) {
      state = state.copyWith(errorMessage: "Account data stream error: $error");
    });

    _woundSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('wound_data')
        .snapshots()
        .listen((snapshot) async {
      final docs = snapshot.docs;

      QueryDocumentSnapshot<Map<String, dynamic>>? infoDoc;
      try {
        infoDoc = docs.firstWhere((doc) => doc.id == 'info');
      } catch (_) {
        infoDoc = null;
      }

      final otherDocs = docs.where((doc) => doc.id != 'info').toList();

      if (otherDocs.isEmpty) return;

      // Get latest image data
      otherDocs.sort((a, b) {
        final aTime =
            (a['imageTimestamp'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
        final bTime =
            (b['imageTimestamp'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
        return bTime.compareTo(aTime);
      });
      final latest = otherDocs.first.data();

      // Combine info + latest
      final combined = {
        ...?infoDoc?.data(),
        ...latest, // latest overrides shared keys
      };

      final wound = Wound.fromMap(combined);
      state = state.copyWith(wound: wound);
    });
  }

  Future<void> loadUserData() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    state = state.copyWith(errorMessage: "No user logged in");
    return;
  }

  state = state.copyWith(isLoading: true, uid: user.uid); 

  try {
    final results = await Future.wait([
      _firestoreService.getUser(user.uid),
      _firestoreService.getAccountInfo(user.uid),
      _firestoreService.getWound(user.uid),
    ]);

    state = state.copyWith(
      appUser: results[0] as AppUser?,
      account: results[1] as Account?,
      wound: results[2] as Wound?,
      isLoading: false,
    );
  } catch (e) {
    state = state.copyWith(
        errorMessage: "Error loading user data: $e", isLoading: false);
  }
}


  Future<void> initializeNewUser(
      String uid, String fName, String lName, String email) async {
    if (state.appUser != null) return;

    final appUser =
        AppUser(email: email, fName: fName, lName: lName, profilePic: "");
    final account = Account(
      bio: "",
      medNote: "",
      darkMode: false,
      enabledNotifications: true,
      dateCreated: Timestamp.now(),
    );
    final wound = Wound(
      woundStatus: "",
      woundImages: [],
      imageTimestamp: Timestamp.now(),
      lastSynced: Timestamp.now(),
      colour: "Green",
      cfu: 1.0,
      insightsMessage:
          "Status: No data available yet. Please take a wound image to receive insights.",
      insightsTip:
          "Tip: Capture a clear image or select a wound color to begin analysis.",
    );

    try {
      await _firestoreService.setUserData(uid, appUser, account, wound);
      await loadUserData();
    } catch (e) {
      state = state.copyWith(errorMessage: "Failed to initialize user: $e");
    }
  }

  Future<void> updateProfilePicture(Uint8List imageBytes) async {
    if (state.uid == null || state.appUser == null) return;

    try {
      final downloadUrl =
          await _storageService.uploadProfilePicture(state.uid!, imageBytes);

      if (downloadUrl != null) {
        await _firestoreService.updateUser(state.uid!, {
          'profilePic': downloadUrl,
        });

        // Explicitly reload user data after updating Firestore
        await loadUserData();
      }
    } catch (e) {
      state =
          state.copyWith(errorMessage: "Failed to update profile picture: $e");
    }
  }

  Future<void> updateBio(String newBio) async {
    if (state.account == null) return;

    final updatedAccount = state.account!.copyWith(bio: newBio);
    state = state.copyWith(account: updatedAccount);

    await _firestoreService.updateAccount(
        state.uid!, updatedAccount.toFirestore());
  }

  Future<void> updateMedicalNotes(String newNotes) async {
    if (state.account == null) return;

    final updatedAccount = state.account!.copyWith(medNote: newNotes);
    state = state.copyWith(account: updatedAccount);

    await _firestoreService.updateAccount(
        state.uid!, updatedAccount.toFirestore());
  }

  Future<void> updateWoundStatus(String newStatus) async {
    if (state.uid == null || state.wound == null) return;

    final updatedWound = state.wound!.copyWith(woundStatus: newStatus);
    state = state.copyWith(wound: updatedWound);

    await _firestoreService.updateWound(state.uid!, updatedWound.toFirestore());
  }

  Future<void> deleteUserData(String uid) async {
    try {
      await _firestoreService.deleteAllUserData(uid);
    } catch (e) {
      state = state.copyWith(errorMessage: "Failed to delete user data: $e");
    }
  }

  Future<void> updateUserEmail(String uid, String newEmail) async {
    try {
      await _firestoreService.updateUser(uid, {"email": newEmail});
      final updatedUser = state.appUser?.copyWith(email: newEmail);
      state = state.copyWith(appUser: updatedUser);
    } catch (e) {
      throw Exception("Failed to update email in Firestore: $e");
    }
  }

  void resetUserData() {
    _cancelSubscriptions();
    state = UserState();
  }

  void _cancelSubscriptions() {
    _userSubscription?.cancel();
    _accountSubscription?.cancel();
    _woundSubscription?.cancel();
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }
}
