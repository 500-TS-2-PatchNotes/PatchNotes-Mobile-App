import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:patchnotes/providers/auth_provider.dart';
import 'package:patchnotes/providers/user_provider.dart';
import 'package:patchnotes/states/settings_state.dart';
import 'package:patchnotes/services/firestore_service.dart';

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final auth = ref.watch(firebaseAuthProvider); 
  final notifier = SettingsNotifier(ref.read(firestoreServiceProvider), auth);

  auth.authStateChanges().listen((user) {
    if (user == null) {
      notifier.resetSettings();
    } else {
      notifier.loadSettings(); 
    }
  });

  return notifier;
});

class SettingsNotifier extends StateNotifier<SettingsState> {
  final FirestoreService _firestoreService;
  final FirebaseAuth _auth;

  SettingsNotifier(this._firestoreService, this._auth)
      : super(SettingsState()) {
    loadSettings(); 
  }

  Future<void> loadSettings() async {
    final user = _auth.currentUser;
    if (user == null) {
      if (mounted) state = state.copyWith(isLoading: false);
      return;
    }

    if (mounted) state = state.copyWith(isLoading: true);

    try {
      final account = await _firestoreService.getAccountInfo(user.uid);
      if (account != null) {
        if (mounted) {
          state = state.copyWith(
            darkMode: account.darkMode,
            notificationsEnabled: account.enabledNotifications,
            isLoading: false,
          );
        }
      } else {
        if (mounted) state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
            errorMessage: "Error loading settings: $e", isLoading: false);
      }
    }
  }

  void resetSettings() {
    if (!mounted) return;
    state = SettingsState();
    print("🔄 User data reset");
  }

  Future<void> toggleDarkMode() async {
    final user = _auth.currentUser;
    if (user == null || !mounted) return;

    final newDarkMode = !state.darkMode;

    if (mounted) state = state.copyWith(darkMode: newDarkMode);

    await _firestoreService.updateAccount(user.uid, {"darkMode": newDarkMode});
  }

  Future<void> toggleNotifications() async {
    final user = _auth.currentUser;
    if (user == null || !mounted) return;

    final newNotifications = !state.notificationsEnabled;

    if (mounted) state = state.copyWith(notificationsEnabled: newNotifications);

    await _firestoreService
        .updateAccount(user.uid, {"enabledNotifications": newNotifications});
  }
}
