import 'package:flutter/material.dart';
import 'package:patchnotes/viewmodels/bacterial_growth.dart';
import 'package:patchnotes/views/mainscreen.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/top_navbar.dart';
import '../bluetooth/scanner.dart';

class DashboardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final growthVM = Provider.of<BacterialGrowthViewModel>(context);

    return Scaffold(
      appBar: const Header(title: "Dashboard"),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStateIndicator(growthVM),
          const SizedBox(height: 10),
          _buildChart(growthVM),
          const SizedBox(height: 20),
          _buildActionButtons(context, growthVM),
        ],
      ),
    );
  }

  Widget _buildStateIndicator(BacterialGrowthViewModel growthVM) {
    String state = growthVM.currentState;
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

  Widget _buildChart(BacterialGrowthViewModel growthVM) {
    List<FlSpot> chartData = growthVM.dataPoints
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
      BuildContext context, BacterialGrowthViewModel growthVM) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildElevatedButton("Patient History", () {
          mainScreenKey.currentState?.onTabTapped(1);
        }),
        _buildElevatedButton("Sync Device", () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScannerPage(
                onDeviceSelected: (device) async {
                  await device.connect();
                },
              ),
            ),
          );
        }),
      ],
    );
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
}
