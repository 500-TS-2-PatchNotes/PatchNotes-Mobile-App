import 'dart:async';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patchnotes/providers/calibration_provider.dart';
import 'package:patchnotes/models/calibration_level.dart';

class GraphPage extends ConsumerStatefulWidget {
  const GraphPage({Key? key}) : super(key: key);

  @override
  ConsumerState<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends ConsumerState<GraphPage> {
  List<FlSpot> chartData = [FlSpot(0, 0)];
  double currentTime = 0;
  double cfuValue = 0;
  String currentState = 'Healthy';
  Color stateColor = Colors.cyan.withOpacity(0.5);
  Timer? _timer;
  bool _started = false;

  void _startGraph(List<CalibrationLevel> levels) {
    if (_started) return;
    _started = true;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        final logMin = 0; // log10(1)
        final logMax = 6; // log10(1e6)
        final exponent = Random().nextDouble() * (logMax - logMin) + logMin;
        cfuValue = pow(10, exponent).roundToDouble();

        currentState = _getWoundState(cfuValue, levels);
        stateColor = _getStateBackgroundColor(currentState);

        chartData.add(FlSpot(currentTime, cfuValue));
        currentTime += 1;

        if (chartData.length > 30) {
          chartData.removeAt(0);
        }

        chartData = List.generate(
          chartData.length,
          (i) => FlSpot(i.toDouble(), chartData[i].y),
        );
      });
    });

    print('Running _startGraph');
    for (final level in levels) {
      print(
          'Level -> cfu: ${level.cfu}, state: ${level.healthState}, color: ${level.color.value}');
    }
  }

  String _getWoundState(double growth, List<CalibrationLevel> levels) {
    final sorted = List<CalibrationLevel>.from(levels)
      ..sort((a, b) => a.cfu.compareTo(b.cfu));

    String matchedState = sorted.first.healthState;
    for (final level in sorted) {
      if (growth >= level.cfu) {
        matchedState = level.healthState;
      } else {
        break;
      }
    }
    return matchedState;
  }

  Color _getStateBackgroundColor(String state) {
    return switch (state) {
      'Healthy' => Colors.cyan.withOpacity(0.5),
      'Moderate' => Colors.orange.withOpacity(0.5),
      'Critical' => Colors.purple.withOpacity(0.5),
      _ => Colors.grey.withOpacity(0.5),
    };
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final calibAsync = ref.watch(calibrationStreamProvider);

    calibAsync.whenData((levels) {
      if (levels.isNotEmpty) {
        _startGraph(levels);
      }
    });

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: stateColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                currentState,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              height: 300,
              width: double.infinity,
              child: LineChart(
                LineChartData(
                  clipData: FlClipData.all(),
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, _) {
                          const values = [
                            0.0,
                            10.0,
                            100.0,
                            1e3,
                            1e4,
                            1e5,
                            1e6
                          ];
                          const labels = [
                            '0',
                            '1e+1',
                            '1e+2',
                            '1e+3',
                            '1e+4',
                            '1e+5',
                            '1e+6'
                          ];
                          for (int i = 0; i < values.length; i++) {
                            if ((value - values[i]).abs() < 1e-1) {
                              return Text(labels[i]);
                            }
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, _) => Text(
                          '${value.toInt()}s',
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  minX: chartData.isNotEmpty ? chartData.first.x : 0,
                  maxX: chartData.isNotEmpty ? chartData.last.x + 30 : 30,
                  minY: 0,
                  maxY: 1e6,
                  lineBarsData: [
                    LineChartBarData(
                      spots: chartData,
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [
                          theme.primaryColor,
                          theme.colorScheme.secondary
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      barWidth: 3,
                      belowBarData: BarAreaData(show: false),
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'CFU: ${cfuValue.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Note: This is a simulated prediction based on current calibration.',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
