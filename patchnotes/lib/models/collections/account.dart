import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:patchnotes/models/notifications_model.dart';

class Account {
  final String bio;
  final String medNote;
  final bool darkMode;
  final bool enabledNotifications;
  final Timestamp dateCreated;

  Account({
    required this.bio,
    required this.medNote,
    required this.darkMode,
    required this.enabledNotifications,
    required this.dateCreated,
  });  

  factory Account.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      return Account(
        bio: "",
        medNote: "",
        darkMode: false,
        enabledNotifications: true,
        dateCreated: Timestamp.now(),
      );
    }
    return Account(
      bio: data['bio'] ?? "",
      medNote: data['medNote'] ?? "",
      darkMode: data['darkMode'] ?? false,
      enabledNotifications: data['enabledNotifications'] ?? true,
      dateCreated: data['dateCreated'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "bio": bio,
      "medNote": medNote,
      "darkMode": darkMode,
      "enabledNotifications": enabledNotifications,
      "dateCreated": dateCreated,
    };
  }

  Account copyWith({
    String? bio,
    String? woundStatus,
    String? medNote,
    bool? darkMode,
    bool? enabledNotifications,
    Timestamp? dateCreated,
    List<NotificationItem>? notifications,
  }) {
    return Account(
      bio: bio ?? this.bio,
      medNote: medNote ?? this.medNote,
      darkMode: darkMode ?? this.darkMode,
      enabledNotifications: enabledNotifications ?? this.enabledNotifications,
      dateCreated: dateCreated ?? this.dateCreated,
    );
  }
}
