import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:patchnotes/providers/bg_provider.dart';
import 'package:patchnotes/providers/bluetooth_provider.dart';
import 'package:patchnotes/states/bg_state.dart';
import '../providers/navigation.dart';
import '../widgets/top_navbar.dart';
import '../bluetooth/scanner.dart';

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  @override
  Widget build(BuildContext context) {
    final growthState = ref.watch(bacterialGrowthProvider);
    final tabIndexNotifier = ref.read(tabIndexProvider.notifier);
    
    return Scaffold(
      appBar: const Header(title: "Dashboard"),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStateIndicator(growthState),
          const SizedBox(height: 10),
          _buildChart(growthState),
          const SizedBox(height: 20),
          const SizedBox(height: 10),
          _buildActionButtons(context, tabIndexNotifier),
        ],
      ),
    );
  }

  Widget _buildStateIndicator(BacterialGrowthState growthState) {
    String state = growthState.currentState;
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
  }

  Widget _buildChart(BacterialGrowthState growthState) {
    List<FlSpot> chartData = growthState.dataPoints
        .map((point) => FlSpot(point.time, point.growthRate))
        .toList();

    return SizedBox(
      height: 250,
      child: LineChart(
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
          minX: chartData.isNotEmpty ? chartData.first.x : 0,
          maxX: chartData.isNotEmpty ? chartData.last.x + 30 : 30,
          minY: 0,
          maxY: 50,
          lineBarsData: [
            LineChartBarData(
              spots: chartData,
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
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, StateController<int> tabIndexNotifier) {
    return Consumer(
      builder: (context, ref, child) {
        final bluetoothState = ref.watch(bluetoothProvider);
        final bluetoothNotifier = ref.watch(bluetoothProvider.notifier);
        BluetoothDevice? connectedDevice = bluetoothState.connectedDevice;
        bool isConnected = connectedDevice != null;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B9BD5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                elevation: 5,
              ),
              onPressed: () {
                tabIndexNotifier.state = 1;
              },
              icon: const Icon(Icons.history, color: Colors.white),
              label: const Text('Patient History',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isConnected ? Colors.red : const Color(0xFF5B9BD5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                elevation: 5,
              ),
              onPressed: () async {
                if (!isConnected) {
                  final selectedDevice = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScannerPage(
                        onDeviceSelected: (device) async {
                          if (device != null) {
                            bool success =
                                await bluetoothNotifier.connectToDevice(device);
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Device connected successfully!",
                                      textAlign: TextAlign.center),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Failed to connect device.",
                                      textAlign: TextAlign.center),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  );

                  if (selectedDevice != null) {
                    ref.refresh(bluetoothProvider);
                  }
                } else {
                  await bluetoothNotifier.disconnectDevice();
                  ref.refresh(bluetoothProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Device disconnected.",
                          textAlign: TextAlign.center),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              icon: Icon(
                isConnected ? Icons.bluetooth_disabled : Icons.bluetooth,
                color: Colors.white,
              ),
              label: Text(
                isConnected ? "Disconnect Device" : "Sync Device",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getStateBackgroundColor(String state) {
    switch (state) {
      case 'Healthy':
        return Colors.cyan.withOpacity(0.5);
      case 'Observation':
        return Colors.amber.withOpacity(0.5);
      case 'Early':
        return Colors.orange.withOpacity(0.5);
      case 'Severe':
        return Colors.red.withOpacity(0.5);
      case 'Critical':
        return Colors.purple.withOpacity(0.5);
      default:
        return Colors.grey.withOpacity(0.5);
    }
  }
}
