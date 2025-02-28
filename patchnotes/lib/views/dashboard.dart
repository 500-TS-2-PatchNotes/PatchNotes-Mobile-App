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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const Header(title: "Dashboard"),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStateIndicator(growthState, theme),
          const SizedBox(height: 10),
          _buildChart(growthState, theme),
          const SizedBox(height: 20),
          _buildActionButtons(context, tabIndexNotifier, theme),
        ],
      ),
    );
  }

  Widget _buildStateIndicator(BacterialGrowthState growthState, ThemeData theme) {
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
          color: state == 'Observation' ? theme.textTheme.bodyLarge?.color : Colors.white,
        ),
      ),
    );
  }

  Widget _buildChart(BacterialGrowthState growthState, ThemeData theme) {
    List<FlSpot> chartData = growthState.dataPoints
        .map((point) => FlSpot(point.time, point.growthRate))
        .toList();

    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            drawHorizontalLine: true,
            getDrawingVerticalLine: (value) => FlLine(
              color: theme.colorScheme.onBackground.withOpacity(0.2),
              strokeWidth: 1,
            ),
            getDrawingHorizontalLine: (value) => FlLine(
              color: theme.colorScheme.onBackground.withOpacity(0.2),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 10,
                getTitlesWidget: (value, _) => Text(
                  '${value.toInt()} CFU',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 5,
                getTitlesWidget: (value, _) => Text(
                  '${value.toInt()}s',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          minX: chartData.isNotEmpty ? chartData.first.x : 0,
          maxX: chartData.isNotEmpty ? chartData.last.x + 30 : 30,
          minY: 0,
          maxY: 50,
          lineBarsData: [
            LineChartBarData(
              spots: chartData,
              isCurved: true,
              gradient: LinearGradient(
                colors: [theme.primaryColor, theme.colorScheme.secondary],
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
      BuildContext context, StateController<int> tabIndexNotifier, ThemeData theme) {
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
                backgroundColor: theme.primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                elevation: 5,
              ),
              onPressed: () {
                tabIndexNotifier.state = 1;
              },
              icon: const Icon(Icons.history, color: Colors.white),
              label: const Text('Patient History',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isConnected ? Colors.red : theme.primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
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
                            bool success = await bluetoothNotifier.connectToDevice(device);
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Device connected successfully!",
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
                isConnected ? "Disconnect" : "Sync Device",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getStateBackgroundColor(String state) {
    return switch (state) {
      'Healthy' => Colors.cyan.withOpacity(0.5),
      'Observation' => Colors.amber.withOpacity(0.5),
      'Early' => Colors.orange.withOpacity(0.5),
      'Severe' => Colors.red.withOpacity(0.5),
      'Critical' => Colors.purple.withOpacity(0.5),
      _ => Colors.grey.withOpacity(0.5),
    };
  }
}
