import 'package:cloud_firestore/cloud_firestore.dart';

class Wound {
  String? woundStatus;
  List<String>? woundImages;
  Timestamp? imageTimestamp;
  Timestamp? lastSynced;
  String? colour;
  double? cfu;
  String? insightsMessage;
  String? insightsTip;

  Wound({
    this.woundStatus,
    this.woundImages,
    this.imageTimestamp,
    this.lastSynced,
    this.colour,
    this.cfu,
    this.insightsMessage,
    this.insightsTip,
  });

  factory Wound.fromMap(Map<String, dynamic>? data) {
    if (data == null) return Wound();

    return Wound(
      woundStatus: data['woundStatus'] ?? "",
      woundImages: List<String>.from(data['woundImages'] ?? []),
      imageTimestamp: data['imageTimestamp'] is Timestamp
          ? data['imageTimestamp'] as Timestamp
          : Timestamp.fromMillisecondsSinceEpoch(
              int.tryParse(data['imageTimestamp'].toString()) ?? 0),
      lastSynced: data['lastSynced'] is Timestamp
          ? data['lastSynced'] as Timestamp
          : Timestamp.fromMillisecondsSinceEpoch(
              int.tryParse(data['lastSynced'].toString()) ?? 0),
      colour: data['colour'] ?? "",
      cfu: (data['cfu'] ?? 0.0).toDouble(),
      insightsMessage: data['insightsMessage'] ?? "",
      insightsTip: data['insightsTip'] ?? "",
    );
  }

  factory Wound.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();

    if (data == null) {
      return Wound();
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
      insightsMessage: data['insightsMessage'],
      insightsTip: data['insightsTip'],
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
      if (insightsMessage != null) "insightsMessage": insightsMessage,
      if (insightsTip != null) "insightsTip": insightsTip,
    };
  }

  Wound copyWith({
    String? woundStatus,
    List<String>? woundImages,
    Timestamp? imageTimestamp,
    Timestamp? lastSynced,
    String? colour,
    double? cfu,
    String? insightsMessage,
    String? insightsTip,
  }) {
    return Wound(
      woundStatus: woundStatus ?? this.woundStatus,
      woundImages: woundImages ?? this.woundImages,
      imageTimestamp: imageTimestamp ?? this.imageTimestamp,
      lastSynced: lastSynced ?? this.lastSynced,
      colour: colour ?? this.colour,
      cfu: cfu ?? this.cfu,
      insightsMessage: insightsMessage ?? this.insightsMessage,
      insightsTip: insightsTip ?? this.insightsTip,
    );
  }
}
