import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:patchnotes/models/notifications_model.dart';

class Account {
  final String bio;
  final String woundStatus;
  final String medNote;
  final bool darkMode;
  final bool enabledNotifications;
  final Timestamp dateCreated;
  final List<NotificationItem> notifications; 

  Account({
    required this.bio,
    required this.woundStatus,
    required this.medNote,
    required this.darkMode,
    required this.enabledNotifications,
    required this.dateCreated,
    this.notifications = const [],
  });  

  factory Account.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      return Account(
        bio: "",
        woundStatus: "",
        medNote: "",
        darkMode: false,
        enabledNotifications: true,
        dateCreated: Timestamp.now(),
        notifications: [],
      );
    }
    return Account(
      bio: data['bio'] ?? "",
      woundStatus: data['woundStatus'] ?? "",
      medNote: data['medNote'] ?? "",
      darkMode: data['darkMode'] ?? false,
      enabledNotifications: data['enabledNotifications'] ?? true,
      dateCreated: data['dateCreated'] ?? Timestamp.now(),
      notifications: (data['notifications'] as List<dynamic>?)
              ?.map((item) => NotificationItem.fromMap(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "bio": bio,
      "woundStatus": woundStatus,
      "medNote": medNote,
      "darkMode": darkMode,
      "enabledNotifications": enabledNotifications,
      "dateCreated": dateCreated,
      "notifications": notifications.map((n) => n.toFirestore()).toList(), 
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
      woundStatus: woundStatus ?? this.woundStatus,
      medNote: medNote ?? this.medNote,
      darkMode: darkMode ?? this.darkMode,
      enabledNotifications: enabledNotifications ?? this.enabledNotifications,
      dateCreated: dateCreated ?? this.dateCreated,
      notifications: notifications ?? this.notifications, 
    );
  }
}
