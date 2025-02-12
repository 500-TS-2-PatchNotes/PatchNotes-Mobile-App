import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:patchnotes/widgets/top_navbar.dart';
import 'package:patchnotes/pages/mainscreen.dart';
import 'package:patchnotes/bluetooth/manager.dart'; // Bluetooth logic
import 'package:patchnotes/bluetooth/scanner.dart'; // Scanner UI
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BacterialGrowthController {
  static final BacterialGrowthController _instance =
      BacterialGrowthController._internal();

  factory BacterialGrowthController() => _instance;

  BacterialGrowthController._internal() {
    _startGraph();
  }

  final List<FlSpot> _dataPoints = [FlSpot(0, 0)];
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
  final BacterialGrowthController controller;
  DashboardPage({super.key, required this.controller});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late BacterialGrowthController controller;
  late String currentState;
  StreamSubscription<String>? _stateSubscription;
  BluetoothDevice? connectedDevice; // Store the selected device

  @override
  void initState() {
    super.initState();
    controller = BacterialGrowthController();
    currentState = controller.currentState;

    _stateSubscription = controller.stateStream.listen((state) {
      if (mounted) {
        setState(() => currentState = state);
      }
    });
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    super.dispose();
  }

  void _onDeviceSelected(BluetoothDevice device) {
    setState(() {
      connectedDevice = device;
    });
  }

  void _disconnectDevice() async {
    if (connectedDevice != null) {
      await connectedDevice!.disconnect();
      setState(() {
        connectedDevice = null; // Reset the connection
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Disconnected"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(title: "Dashboard"),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStateIndicator(),
          const SizedBox(height: 10),
          _buildChart(),
          const SizedBox(height: 20),
          if (connectedDevice != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Connected to: ${connectedDevice!.platformName}",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildStateIndicator() {
    return StreamBuilder<String>(
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
    );
  }

  Widget _buildChart() {
    return SizedBox(
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
                    getTitlesWidget: (value, _) => Text('${value.toInt()} CFU',
                        style: const TextStyle(fontSize: 12)),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 5,
                    getTitlesWidget: (value, _) => Text('${value.toInt()}s',
                        style: const TextStyle(fontSize: 12)),
                  ),
                ),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              minX: snapshot.data!.isNotEmpty ? snapshot.data!.first.x : 0,
              maxX: snapshot.data!.isNotEmpty ? snapshot.data!.last.x + 30 : 30,
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
    );
  }

  Color _getStateBackgroundColor(String state) {
    switch (state) {
      case 'Healthy':
        return Colors.cyan.withOpacity(0.5);
      case 'Observation':
        return Colors.amber.withOpacity(0.5);
      case 'Early Infection':
        return Colors.orange.withOpacity(0.5);
      case 'Severe Infection':
        return Colors.red.withOpacity(0.5);
      case 'Critical':
        return Colors.purple.withOpacity(0.5);
      default:
        return Colors.grey.withOpacity(0.5);
    }
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildElevatedButton("Patient History", () {
          mainScreenKey.currentState?.onTabTapped(1);
        }),
        connectedDevice == null
            ? _buildElevatedButton("Sync Device", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ScannerPage(onDeviceSelected: _onDeviceSelected),
                  ),
                );
              })
            : _buildElevatedButton("Disconnect", _disconnectDevice),
      ],
    );
  }
}

Widget _buildElevatedButton(String text, VoidCallback? onPressed) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF5B9BD5).withOpacity(0.8),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    child: Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  );
}
