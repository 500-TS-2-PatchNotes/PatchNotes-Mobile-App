import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patchnotes/providers/calibration_provider.dart';
import 'package:patchnotes/models/calibration_level.dart';
import 'dart:math';

class CalibrationPage extends ConsumerWidget {
  const CalibrationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calibAsync = ref.watch(calibrationStreamProvider);
    final healthStates = ['Healthy', 'Moderate', 'Critical'];

    // Default levels
    final defaultColorLevels = [
      CalibrationLevel(cfu: 1.0, color: const Color(0xFFF1BB00), healthState: 'Healthy'),
      CalibrationLevel(cfu: pow(10, 1).toDouble(), color: const Color(0xFFF8B102), healthState: 'Healthy'),
      CalibrationLevel(cfu: pow(10, 2).toDouble(), color: const Color(0xFFE7B21A), healthState: 'Healthy'),
      CalibrationLevel(cfu: pow(10, 3).toDouble(), color: const Color(0xFF91A55E), healthState: 'Moderate'),
      CalibrationLevel(cfu: pow(10, 4).toDouble(), color: const Color(0xFF47899A), healthState: 'Moderate'),
      CalibrationLevel(cfu: pow(10, 5).toDouble(), color: const Color(0xFF1072BC), healthState: 'Critical'),
      CalibrationLevel(cfu: pow(10, 6).toDouble(), color: const Color(0xFF016BC8), healthState: 'Critical'),
    ];

    return calibAsync.when(
      data: (levelsFromFirestore) {
        // Fallback to default if Firestore is empty
        final levels = levelsFromFirestore.isEmpty ? defaultColorLevels : levelsFromFirestore;

        final editedLevels = ref.watch(editedLevelsProvider(levels));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Calibration Thresholds',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: editedLevels.length,
                itemBuilder: (context, index) {
                  final level = editedLevels[index];

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: level.color,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.black26),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'CFU: ${level.cfu == 1.0 ? '0' : level.cfu.toStringAsExponential(1)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: level.healthState,
                            decoration: InputDecoration(
                              labelText: 'Assign Health State',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                            ),
                            items: healthStates.map((state) {
                              return DropdownMenuItem<String>(
                                value: state,
                                child: Text(state),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                ref
                                    .read(editedLevelsProvider(levels).notifier)
                                    .updateLevel(index, value);
                              }
                            },
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Note: This setting affects predictive color calibration.',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final updater = ref.read(calibrationUpdaterProvider);
                    await updater(editedLevels);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Calibration settings saved!',
                            textAlign: TextAlign.center),
                        backgroundColor: Colors.green.shade600,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF9696D9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    'Save Changes',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error loading calibration: $e')),
    );
  }
}
