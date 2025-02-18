import 'package:cloud_firestore/cloud_firestore.dart';

class Wound {
  String? woundStatus;
  List<String>? woundImages;
  Timestamp? imageTimestamp;
  Timestamp? lastSynced;
  String? colour;
  double? cfu;

  Wound({
    this.woundStatus,
    this.woundImages,
    this.imageTimestamp,
    this.lastSynced,
    this.colour,
    this.cfu,
  });

  factory Wound.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();

    if (data == null) {
      return Wound(); // Return an empty Wound object if data is null
    }

    return Wound(
      woundStatus: data['woundStatus'],
      woundImages: data['woundImages'] is List
          ? List<String>.from(data['woundImages'])
          : null,

      imageTimestamp: data['imageTimestamp'] is Timestamp
          ? data['imageTimestamp'] as Timestamp
          : null,
      lastSynced: data['lastSynced'] is Timestamp
          ? data['lastSynced'] as Timestamp
          : null,

      colour: data['colour'],

      cfu: (data['cfu'] is num) ? (data['cfu'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (woundStatus != null) "woundStatus": woundStatus,
      if (woundImages != null) "woundImages": woundImages,
      
      if (imageTimestamp != null) "imageTimestamp": imageTimestamp,
      if (lastSynced != null) "lastSynced": lastSynced,
      
      if (colour != null) "colour": colour,
      if (cfu != null) "cfu": cfu,
    };
  }
}
