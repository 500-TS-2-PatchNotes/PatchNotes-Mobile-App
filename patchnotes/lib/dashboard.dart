import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BacterialGrowthController {
  static final BacterialGrowthController _instance = BacterialGrowthController._internal();

  factory BacterialGrowthController() => _instance;

  BacterialGrowthController._internal() {
    _startGraph();
  }

  final List<FlSpot> _dataPoints = [];
  double _currentTime = 0;
  String _currentState = 'Healthy';
  Timer? _timer;

  final _dataStreamController = StreamController<List<FlSpot>>.broadcast();
  final _stateStreamController = StreamController<String>.broadcast();

  Stream<List<FlSpot>> get dataStream => _dataStreamController.stream;
  Stream<String> get stateStream => _stateStreamController.stream;

  List<FlSpot> get dataPoints => _dataPoints;
  String get currentState => _currentState;

  void _startGraph() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final randomGrowth = Random().nextDouble() * 50;
      _dataPoints.add(FlSpot(_currentTime, randomGrowth));
      _currentTime += 1;

      _currentState = _getWoundState(randomGrowth);

      if (_dataPoints.length > 30) {
        _dataPoints.removeAt(0);
      }

      // Update streams safely
      if (_dataStreamController.hasListener) {
        _dataStreamController.add(List.from(_dataPoints));
      }
      if (_stateStreamController.hasListener) {
        _stateStreamController.add(_currentState);
      }
    });
  }

  String _getWoundState(double growth) {
    if (growth < 10) return 'Healthy';
    if (growth < 20) return 'Observation';
    if (growth < 30) return 'Early Infection';
    if (growth < 40) return 'Severe Infection';
    return 'Critical';
  }

  void dispose() {
    _timer?.cancel();
    _dataStreamController.close();
    _stateStreamController.close();
  }
}

class DashboardPage extends StatefulWidget {
  final Function(int) onNavigate;

  const DashboardPage({required this.onNavigate, super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late BacterialGrowthController controller;
  late String currentState;
  StreamSubscription<String>? _stateSubscription;

  @override
  void initState() {
    super.initState();
    controller = BacterialGrowthController();
    currentState = controller.currentState;

    // Listen to state updates, but check if mounted before updating UI
    _stateSubscription = controller.stateStream.listen((state) {
      if (mounted) {
        setState(() {
          currentState = state;
        });
      }
    });
  }

  @override
  void dispose() {
    _stateSubscription?.cancel(); // Cancel the stream subscription to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StreamBuilder<String>(
          stream: controller.stateStream,
          initialData: controller.currentState,
          builder: (context, snapshot) {
            String state = snapshot.data ?? 'Healthy';
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: _getStateBackgroundColor(state),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                state,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: state == 'Observation' ? Colors.black : Colors.white,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 250,
          child: StreamBuilder<List<FlSpot>>(
            stream: controller.dataStream,
            initialData: controller.dataPoints,
            builder: (context, snapshot) {
              return LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 10,
                        getTitlesWidget: (value, _) => Text(
                          '${value.toInt()} CFU',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 5,
                        getTitlesWidget: (value, _) => Text(
                          '${value.toInt()}s',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  minX: snapshot.data!.isNotEmpty ? snapshot.data!.first.x : 0,
                  maxX: snapshot.data!.isNotEmpty
                      ? snapshot.data!.last.x + 30
                      : 30,
                  minY: 0,
                  maxY: 50,
                  lineBarsData: [
                    LineChartBarData(
                      spots: snapshot.data ?? [],
                      isCurved: true,
                      gradient: const LinearGradient(
                        colors: [Colors.blue, Colors.green],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      barWidth: 3,
                      belowBarData: BarAreaData(show: false),
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                widget.onNavigate(1); // Navigate to Insights Page
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B9BD5).withOpacity(0.8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Patient History',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B9BD5).withOpacity(0.8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Sync Device',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getStateBackgroundColor(String state) {
    switch (state) {
      case 'Healthy':
        return const Color(0xFF80DEEA).withOpacity(0.5); // Light cyan (cool and fresh)
      case 'Observation':
        return const Color(0xFFFFE082).withOpacity(0.5); // Pastel amber (gentle warning)
      case 'Early Infection':
        return const Color(0xFFFFAB91).withOpacity(0.5); // Soft coral (progressing issue)
      case 'Severe Infection':
        return const Color(0xFFD32F2F).withOpacity(0.5); // Deep red (severe alert)
      case 'Critical':
        return const Color(0xFF512DA8).withOpacity(0.5); // Deep indigo (high-risk, serious tone)
      default:
        return const Color(0xFFB0BEC5).withOpacity(0.5); // Muted blue-grey (neutral)
    }
  }
}
