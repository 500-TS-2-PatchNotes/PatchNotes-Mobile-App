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
import '../models/notifications_model.dart';

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
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _accountSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _woundSubscription;
  
  UserNotifier(this.ref, this._firestoreService, this._storageService) : super(UserState());
  
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

    _userSubscription =
        _firestoreService.userCollection.doc(uid).snapshots().listen(
      (snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          state = state.copyWith(
              appUser:
                  AppUser.fromMap(snapshot.data()! as Map<String, dynamic>?));
        }
      },
      onError: (error) => state =
          state.copyWith(errorMessage: "User data stream error: $error"),
    ) as StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?;

    _accountSubscription =
        _firestoreService.accountCollection.doc(uid).snapshots().listen(
      (snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          state = state.copyWith(
              account:
                  Account.fromMap(snapshot.data()! as Map<String, dynamic>?));
        }
      },
      onError: (error) => state =
          state.copyWith(errorMessage: "Account data stream error: $error"),
    ) as StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?;

    _woundSubscription =
        _firestoreService.woundCollection.doc(uid).snapshots().listen(
      (snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          state = state.copyWith(
              wound: Wound.fromMap(snapshot.data()! as Map<String, dynamic>?));
        }
      },
      onError: (error) => state =
          state.copyWith(errorMessage: "Wound data stream error: $error"),
    ) as StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?;
  }

  Future<void> loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      state = state.copyWith(errorMessage: "No user logged in");
      return;
    }

    if (state.appUser != null && state.account != null && state.wound != null)
      return;

    state = state.copyWith(isLoading: true, uid: user.uid);

    try {
      final results = await Future.wait([
        _firestoreService.getUser(user.uid),
        _firestoreService.getAccountInfo(user.uid),
        _firestoreService.getWound(user.uid),
      ]);

      state = state.copyWith(
        appUser: results[0] != null
            ? AppUser.fromMap(results[0]! as Map<String, dynamic>?)
            : null,
        account: results[1] != null
            ? Account.fromMap(results[1]! as Map<String, dynamic>?)
            : null,
        wound: results[2] != null
            ? Wound.fromMap(results[2]! as Map<String, dynamic>?)
            : null,
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
      woundStatus: "",
      medNote: "",
      darkMode: false,
      enabledNotifications: true,
      dateCreated: Timestamp.now(),
      notifications: [
        NotificationItem(
            id: '1', title: 'Welcome!', message: 'Thanks for signing up.'),
        NotificationItem(
            id: '2',
            title: 'Update Available',
            message: 'A new update is ready to install.'),
        NotificationItem(
            id: '3',
            title: 'Reminder',
            message: 'Make sure to check for any color changes on your wound.'),
      ],
    );
    final wound = Wound(
      woundStatus: "",
      woundImages: [],
      imageTimestamp: Timestamp.now(),
      lastSynced: Timestamp.now(),
      colour: "",
      cfu: 0.0,
    );

    try {
      await _firestoreService.setUserData(uid, appUser, account, wound);
      await loadUserData();
    } catch (e) {
      state = state.copyWith(errorMessage: "Failed to initialize user: $e");
    }
  }

  /// Mark Notification as Seen
  void markNotificationAsSeen(int index) {
    if (state.account == null || state.account!.notifications.isEmpty) return;

    List<NotificationItem> updatedNotifications =
        List.from(state.account!.notifications);
    updatedNotifications[index] =
        updatedNotifications[index].copyWith(seen: true);

    state = state.copyWith(
      account: state.account!.copyWith(notifications: updatedNotifications),
    );

    _firestoreService.updateAccount(state.uid!, state.account!.toFirestore());
  }

  /// Remove Notification
  void removeNotification(int index) {
    if (state.account == null || state.account!.notifications.isEmpty) return;

    List<NotificationItem> updatedNotifications =
        List.from(state.account!.notifications)..removeAt(index);

    state = state.copyWith(
      account: state.account!.copyWith(notifications: updatedNotifications),
    );

    _firestoreService.updateAccount(state.uid!, state.account!.toFirestore());
  }

  /// Upload & Update Profile Picture
  Future<void> updateProfilePicture(Uint8List imageBytes) async {
    if (state.uid == null || state.appUser == null) return;

    try {
      // Upload the image and get the new download URL
      final downloadUrl =
          await _storageService.uploadProfilePicture(state.uid!, imageBytes);
      if (downloadUrl != null) {
        // Update local state (assuming you're using a StateNotifier)
        state = state.copyWith(
          appUser: state.appUser!.copyWith(profilePic: downloadUrl),
        );
        // Push the update to Firestore
        await _firestoreService.updateUser(
            state.uid!, state.appUser!.toFirestore());
        print("Profile picture updated successfully");
      }
    } catch (e) {
      state =
          state.copyWith(errorMessage: "Failed to update profile picture: $e");
      print("Error updating profile picture: $e");
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
  if (state.uid == null || state.account == null || state.wound == null) return;

  // Create updated versions of your models
  final updatedAccount = state.account!.copyWith(woundStatus: newStatus);
  final updatedWound = state.wound!.copyWith(woundStatus: newStatus);

  // Update local state
  state = state.copyWith(account: updatedAccount, wound: updatedWound);

  // Push changes to Firestore (assuming your Firestore service supports these updates)
  await _firestoreService.updateAccount(state.uid!, updatedAccount.toFirestore());
  await _firestoreService.updateWound(state.uid!, updatedWound.toFirestore());
}

  Future<void> deleteUserData(String uid) async {
    try {
      print("Deleting user data for UID: $uid");

      await _firestoreService.userCollection.doc(uid).delete();
      print("User document deleted");

      await _firestoreService.accountCollection.doc(uid).delete();
      print("Account document deleted");

      await _firestoreService.woundCollection.doc(uid).delete();
      print("Wound document deleted");
    } catch (e) {
      state = state.copyWith(errorMessage: "Failed to delete user data: $e");
      print("Error deleting user data: $e");
    }
  }


  Future<void> updateUserEmail(String uid, String newEmail) async {
  try {
    final firestore = ref.read(firestoreServiceProvider);

    await firestore.userCollection.doc(uid).update({"email": newEmail});

    final updatedUser = state.appUser?.copyWith(email: newEmail);
    state = state.copyWith(appUser: updatedUser);
  } catch (e) {
    throw Exception("Failed to update email in Firestore: $e");
  }
}


  void resetUserData() {
    _cancelSubscriptions();
    state = UserState();
    print("User data reset");
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
