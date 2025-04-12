import 'package:cloud_firestore/cloud_firestore.dart';

class Wound {
  String? woundStatus;
  List<String>? woundImages;
  Timestamp? imageTimestamp;
  Timestamp? lastSynced;
  String? colour;
  double? cfu;
  double? currentLvl;             
  List<double>? recentLevels;     
  String? insightsMessage;
  String? insightsTip;

  Wound({
    this.woundStatus,
    this.woundImages,
    this.imageTimestamp,
    this.lastSynced,
    this.colour,
    this.cfu,
    this.currentLvl,            
    this.recentLevels,           
    this.insightsMessage = "Status: No data available yet. Please take a wound image to receive insights.",
    this.insightsTip = "Tip: Capture a clear image or select a wound color to begin analysis.",
  });

  factory Wound.fromMap(Map<String, dynamic>? data) {
    if (data == null) return Wound();

    return Wound(
      woundStatus: data['woundStatus'] ?? "",
      woundImages: data['woundImages'] != null
          ? List<String>.from(data['woundImages'])
          : [],
      imageTimestamp: _parseTimestamp(data['imageTimestamp']),
      lastSynced: _parseTimestamp(data['lastSynced']),
      colour: data['colour'] ?? "",
      cfu: (data['cfu'] is num) ? (data['cfu'] as num).toDouble() : 0.0,
      currentLvl: (data['currentLvl'] is num) ? (data['currentLvl'] as num).toDouble() : null,
      recentLevels: data['recentLevels'] != null
          ? List<double>.from((data['recentLevels'] as List).map((e) => (e as num).toDouble()))
          : [],
      insightsMessage: data['insightsMessage'] ??
          "Status: No data available yet. Please take a wound image to receive insights.",
      insightsTip: data['insightsTip'] ??
          "Tip: Capture a clear image or select a wound color to begin analysis.",
    );
  }

  factory Wound.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Wound.fromMap(data);
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (woundStatus != null) 'woundStatus': woundStatus,
      if (woundImages != null) 'woundImages': woundImages,
      if (imageTimestamp != null) 'imageTimestamp': imageTimestamp,
      if (lastSynced != null) 'lastSynced': lastSynced,
      if (colour != null) 'colour': colour,
      if (cfu != null) 'cfu': cfu,
      if (currentLvl != null) 'currentLvl': currentLvl,          
      if (recentLevels != null) 'recentLevels': recentLevels,    
      if (insightsMessage != null) 'insightsMessage': insightsMessage,
      if (insightsTip != null) 'insightsTip': insightsTip,
    };
  }

  Wound copyWith({
    String? woundStatus,
    List<String>? woundImages,
    Timestamp? imageTimestamp,
    Timestamp? lastSynced,
    String? colour,
    double? cfu,
    double? currentLvl,             
    List<double>? recentLevels,    
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
      currentLvl: currentLvl ?? this.currentLvl,
      recentLevels: recentLevels ?? this.recentLevels,
      insightsMessage: insightsMessage ?? this.insightsMessage,
      insightsTip: insightsTip ?? this.insightsTip,
    );
  }

  static Timestamp? _parseTimestamp(dynamic value) {
    if (value is Timestamp) return value;
    if (value is int) {
      return Timestamp.fromMillisecondsSinceEpoch(value);
    }
    if (value is String) {
      final ms = int.tryParse(value);
      if (ms != null) {
        return Timestamp.fromMillisecondsSinceEpoch(ms);
      }
    }
    return null;
  }
}
