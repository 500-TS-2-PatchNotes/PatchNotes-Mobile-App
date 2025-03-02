import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

// Define Health States
enum HealthState { Healthy, Observation, Severe, Critical }

extension HealthStateExtension on HealthState {
  String get name {
    switch (this) {
      case HealthState.Healthy:
        return "Healthy";
      case HealthState.Observation:
        return "Observation";
      case HealthState.Severe:
        return "Severe";
      case HealthState.Critical:
        return "Critical";
    }
  }
}

// CFU Thresholds Data Model
class HealthThreshold {
  final String state;
  final double cfuThreshold;

  HealthThreshold({required this.state, required this.cfuThreshold});
}

// Calibration State
class CalibrationState {
  final bool isAdminView;
  final List<FlSpot> calibrationPoints;
  final List<HealthThreshold> healthThresholds;

  CalibrationState({
    required this.isAdminView,
    required this.calibrationPoints,
    required this.healthThresholds,
  });

  CalibrationState copyWith({
    bool? isAdminView,
    List<FlSpot>? calibrationPoints,
    List<HealthThreshold>? healthThresholds,
  }) {
    return CalibrationState(
      isAdminView: isAdminView ?? this.isAdminView,
      calibrationPoints: calibrationPoints ?? this.calibrationPoints,
      healthThresholds: healthThresholds ?? this.healthThresholds,
    );
  }
}

// StateNotifier to Manage Calibration Data
class CalibrationNotifier extends StateNotifier<CalibrationState> {
  CalibrationNotifier()
      : super(CalibrationState(
          isAdminView: true,
          calibrationPoints: [
            FlSpot(1.0, log(10)),
            FlSpot(0.75, log(10e4)), // Observation
            FlSpot(0.50, log(10e5)), // Severe
            FlSpot(0.25, log(10e7)), // Darkest -> Highest CFU (Critical)
          ],
          healthThresholds: [
            HealthThreshold(state: HealthState.Healthy.name, cfuThreshold: 10),
            HealthThreshold(
                state: HealthState.Observation.name,
                cfuThreshold: pow(10, 4).toDouble()),
            HealthThreshold(
                state: HealthState.Severe.name,
                cfuThreshold: pow(10, 5).toDouble()),
            HealthThreshold(
                state: HealthState.Critical.name,
                cfuThreshold: pow(10, 7).toDouble()),
          ],
        ));

  void toggleView() {
    state = state.copyWith(isAdminView: !state.isAdminView);
  }

  void updateThreshold(String healthState, double value) {
    final updatedThresholds = state.healthThresholds.map((threshold) {
      if (threshold.state == healthState) {
        return HealthThreshold(state: healthState, cfuThreshold: value);
      }
      return threshold;
    }).toList();
    state = state.copyWith(healthThresholds: updatedThresholds);
  }

  void updatePoint(int index, double newY) {
    if (index >= 0 && index < state.calibrationPoints.length) {
      final updatedPoints = [...state.calibrationPoints];
      updatedPoints[index] = FlSpot(updatedPoints[index].x, newY);
      state = state.copyWith(calibrationPoints: updatedPoints);
    }
  }
}

// Riverpod Provider
final calibrationProvider =
    StateNotifierProvider<CalibrationNotifier, CalibrationState>(
        (ref) => CalibrationNotifier());

// Admin Panel UI
class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calibrationProvider);
    final notifier = ref.read(calibrationProvider.notifier);

    return Scaffold(
      appBar: AppBar(
  title: Text(state.isAdminView ? 'Admin Panel' : 'User View'),
  leading: IconButton(
    icon: const Icon(Icons.home, size: 28), // Home icon
    tooltip: 'Go to Login',
    onPressed: () {
      Navigator.pushReplacementNamed(context, '/login'); // Adjust route as needed
    },
  ),
  actions: [
    IconButton(
      icon: const Icon(Icons.swap_horiz),
      onPressed: notifier.toggleView,
      tooltip: 'Toggle View',
    ),
  ],
),

      body: state.isAdminView
          ? AdminView(state: state, notifier: notifier)
          : UserView(state: state),
    );
  }
}

// Admin View
class AdminView extends StatelessWidget {
  final CalibrationState state;
  final CalibrationNotifier notifier;

  const AdminView({Key? key, required this.state, required this.notifier})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const SizedBox(height: 10),
    const Text(
      'Calibration Curve',
      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    ),
    const SizedBox(height: 15),
    SizedBox(
      height: 250, 
      width: double.infinity,
      child: CalibrationChart(
        points: state.calibrationPoints,
        onUpdatePoint: notifier.updatePoint,
      ),
    ),
    const SizedBox(height: 10),
    const Text(
      'Adjust CFU Thresholds',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
    Expanded(
      child: ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: state.healthThresholds.map((threshold) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  '${threshold.state} Threshold: ${formatThreshold(threshold.cfuThreshold)} CFU'),
              Slider(
                value: log(threshold.cfuThreshold)
                    .clamp(log(10), log(pow(10, 7))),
                min: log(10),
                max: log(pow(10, 7)), 
                divisions: 20,
                label: formatThreshold(threshold.cfuThreshold),
                onChanged: (value) {
                  notifier.updateThreshold(threshold.state, exp(value));
                },
              ),
            ],
          );
        }).toList(),
      ),
    ),
    const SizedBox(height: 10),
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Changes have been saved!',
                  style: TextStyle(fontSize: 16),
                ),
                backgroundColor: Colors.green.shade600,
                duration: Duration(seconds: 2),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: Colors.purple.shade500, // Button color
          ),
          child: Text(
            'Save Changes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ),
    const SizedBox(height: 20),
  ],
),

    );
  }
}

// User View
class UserView extends StatelessWidget {
  final CalibrationState state;

  const UserView({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: state.healthThresholds.map((threshold) {
          return Text(
            '${threshold.state}: ${formatThreshold(threshold.cfuThreshold)} CFU',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          );
        }).toList(),
      ),
    );
  }
}

// Calibration Chart
class CalibrationChart extends StatelessWidget {
  final List<FlSpot> points;
  final Function(int, double) onUpdatePoint;

  const CalibrationChart({
    Key? key,
    required this.points,
    required this.onUpdatePoint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, horizontalInterval: 1),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            axisNameWidget:
                const Text("CFU (log scale)", style: TextStyle(fontSize: 12)),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 35,
              getTitlesWidget: (value, meta) {
                return Text(formatThreshold(exp(value)),
                    style: TextStyle(fontSize: 10)); // Smaller labels
              },
            ),
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: const Text("Brightness Intensity",
                style: TextStyle(fontSize: 12)),
            sideTitles: SideTitles(
              showTitles: true,
              interval: 0.25, // Ensure proper spacing
              reservedSize: 25, // Reduce space to avoid overlap
              getTitlesWidget: (value, meta) {
                return Text(value.toStringAsFixed(2),
                    style: TextStyle(fontSize: 10)); // Smaller labels
              },
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: points,
            isCurved: true,
            color: Colors.blue,
            barWidth: 4,
            belowBarData:
                BarAreaData(show: true, color: Colors.blue.withOpacity(0.2)),
          ),
        ],
      ),
    );
  }
}

// Helper Functions
String formatThreshold(double value) {
  return value >= 100
      ? value.toStringAsExponential(2)
      : value.toStringAsFixed(2);
}
