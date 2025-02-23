import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  String? email;
  String? fName;
  String? lName;
  String? profilePic;

  AppUser({
    this.email,
    this.fName,
    this.lName,
    this.profilePic,
  });

  factory AppUser.fromMap(Map<String, dynamic>? data) {
    if (data == null) return AppUser();
    return AppUser(
      email: data['email'] as String?,
      fName: data['fName'] as String?,
      lName: data['lName'] as String?,
      profilePic: data['profilePic'] as String?,
    );
  }

  factory AppUser.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return AppUser(
      email: data?['email'],
      fName: data?['fName'],
      lName: data?['lName'],
      profilePic: data?['profilePic'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (email != null) "email": email,
      if (fName != null) "fName": fName,
      if (lName != null) "lName": lName,
      if (profilePic != null) "profilePic": profilePic,
    };
  }

  AppUser copyWith({
    String? email,
    String? fName,
    String? lName,
    String? profilePic,
  }) {
    return AppUser(
      email: email ?? this.email,
      fName: fName ?? this.fName,
      lName: lName ?? this.lName,
      profilePic: profilePic ?? this.profilePic,
    );
  }
}


