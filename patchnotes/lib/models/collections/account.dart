import 'package:cloud_firestore/cloud_firestore.dart';

class Account {
  final String uid; // (foreign). To reference the user's id.
  final String profile_pic;
  final String bio;
  final String wound_status;
  final String med_note;
  final bool dark_mode;
  final bool enabledNotifications;
  final Timestamp date_created;

  Account({
    required this.uid,
    required this.profile_pic,
    required this.bio,
    required this.wound_status,
    required this.med_note,
    required this.dark_mode,
    required this.enabledNotifications,
    required this.date_created,
  });
}
