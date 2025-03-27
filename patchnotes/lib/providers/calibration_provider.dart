import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patchnotes/models/calibration_level.dart';

/// Real-time stream of calibration data from Firestore
final calibrationStreamProvider = StreamProvider<List<CalibrationLevel>>((ref) {
  return FirebaseFirestore.instance
      .collection('calibration')
      .orderBy('cfu') // Ensures levels are sorted by CFU value
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return CalibrationLevel.fromMap(doc.data());
    }).toList();
  });
});

/// Function to batch-update calibration levels in Firestore
final calibrationUpdaterProvider = Provider((ref) {
  return (List<CalibrationLevel> levels) async {
    final batch = FirebaseFirestore.instance.batch();
    final collection = FirebaseFirestore.instance.collection('calibration');

    for (var i = 0; i < levels.length; i++) {
      final docRef = collection.doc('level_$i');
      batch.set(docRef, levels[i].toMap());
    }
    await batch.commit();
  };
});

/// StateNotifierProvider to manage editable calibration levels locally
final editedLevelsProvider = StateNotifierProvider.autoDispose
    .family<EditedLevelsNotifier, List<CalibrationLevel>, List<CalibrationLevel>>(
  (ref, initialLevels) => EditedLevelsNotifier(initialLevels),
);

/// StateNotifier class for updating local calibration level states
class EditedLevelsNotifier extends StateNotifier<List<CalibrationLevel>> {
  EditedLevelsNotifier(List<CalibrationLevel> initial) : super(List.from(initial));

  void updateLevel(int index, String newState) {
    final updated = List<CalibrationLevel>.from(state);
    updated[index] = CalibrationLevel(
      cfu: updated[index].cfu,
      color: updated[index].color,
      healthState: newState,
    );
    state = updated;
  }
}
