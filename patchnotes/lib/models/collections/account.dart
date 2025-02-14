import 'package:cloud_firestore/cloud_firestore.dart';

class Account {
  String? profilePic;
  String? bio;
  String? woundStatus;
  String? medNote;
  bool? darkMode;
  bool? enabledNotifications;
  Timestamp? dateCreated;

  Account({
    this.profilePic,
    this.bio,
    this.woundStatus,
    this.medNote,
    this.darkMode,
    this.enabledNotifications,
    this.dateCreated,
  });

  factory Account.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Account(
      profilePic: data?['profilePic'],
      bio: data?['bio'],
      woundStatus: data?['woundStatus'],
      medNote: data?['medNote'],
      darkMode: data?['darkMode'],
      enabledNotifications: data?['enabledNotifications'],
      dateCreated: data?['dateCreated']
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if(profilePic != null) "profilePic": profilePic,
      if(bio != null) "bio": bio,
      if(woundStatus != null) "woundStatus": woundStatus,
      if(medNote != null) "medNote": medNote,
      if(darkMode != null) "darkMode": darkMode,
      if(enabledNotifications != null) "enabledNotifications": enabledNotifications,
      if(dateCreated != null) "dateCreated": dateCreated
    };
  }

}
