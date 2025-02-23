import 'package:patchnotes/models/collections/account.dart';
import 'package:patchnotes/models/collections/user.dart';
import 'package:patchnotes/models/collections/wound.dart';
import 'package:patchnotes/models/notifications_model.dart';

class UserState {
  final String? uid; // 🔹 Add UID
  final AppUser? appUser;
  final Account? account;
  final Wound? wound;
  final bool isLoading;
  final String? errorMessage;
  final List<NotificationItem>? notifications; 

  UserState({
    this.uid, 
    this.appUser,
    this.account,
    this.wound,
    this.isLoading = false,
    this.errorMessage,
    this.notifications,
  });

  UserState copyWith({
    String? uid, 
    AppUser? appUser,
    Account? account,
    Wound? wound,
    bool? isLoading,
    String? errorMessage,
    List<NotificationItem>? notifications,
  }) {
    return UserState(
      uid: uid ?? this.uid,
      appUser: appUser ?? this.appUser,
      account: account ?? this.account,
      wound: wound ?? this.wound,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      notifications: notifications ?? this.notifications,
    );
  }
}
