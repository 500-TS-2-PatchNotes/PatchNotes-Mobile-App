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
    return Wound(
      woundStatus: data?['woundStatus'],
      woundImages: data?['woundImages'],
      imageTimestamp: data?['imageTimestamp'],
      lastSynced: data?['lastSynced'],
      colour: data?['colour'],
      cfu: data?['cfu'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if(woundStatus != null) "woundStatus": woundStatus,
      if(woundImages != null) "woundImages": woundImages,
      if(imageTimestamp != null) "imageTimestamp": imageTimestamp,
      if(lastSynced != null) "lastSynced": lastSynced,
      if(colour != null) "colour": colour,
      if(cfu != null) "cfu": cfu
    };
  }

}
