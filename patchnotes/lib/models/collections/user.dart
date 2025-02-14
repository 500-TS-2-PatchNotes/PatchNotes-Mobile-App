import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String? email;
  String? fName;
  String? lName;

  User({
    this.email,
    this.fName,
    this.lName,
  });

  factory User.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return User(
      email: data?['email'],
      fName: data?['fName'],
      lName: data?['lName'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (email != null) "state": email,
      if (fName != null) "fName": fName,
      if (lName != null) "capital": lName,
    };
  }
}
