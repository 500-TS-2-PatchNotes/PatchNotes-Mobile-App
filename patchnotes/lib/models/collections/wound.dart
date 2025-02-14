import 'package:cloud_firestore/cloud_firestore.dart';

class Wound {
  final String uid; // (foreign). To reference the user's id.
  final String wound_status;
  final List<String> wound_images;
  final Timestamp image_timestamp;
  final Timestamp last_synced;
  final String colour;
  final double cfu;

  Wound({
    required this.uid,
    required this.wound_status,
    required this.wound_images,
    required this.image_timestamp,
    required this.last_synced,
    required this.colour,
    required this.cfu,
  });
}
