import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:patchnotes/models/bacterial_growth.dart';

class BacterialGrowthChart extends StatelessWidget {
  final Stream<List<BacterialGrowth>> dataStream;
  final List<BacterialGrowth> initialData;

  const BacterialGrowthChart({Key? key, required this.dataStream, required this.initialData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: StreamBuilder<List<BacterialGrowth>>(
        stream: dataStream,
        initialData: initialData,
        builder: (context, snapshot) {
          return LineChart(
            LineChartData(
              minX: snapshot.data!.isNotEmpty ? snapshot.data!.first.time : 0,
              maxX: snapshot.data!.isNotEmpty ? snapshot.data!.last.time + 30 : 30,
              minY: 0,
              maxY: 50,
              lineBarsData: [
                LineChartBarData(
                  spots: snapshot.data!.map((d) => FlSpot(d.time, d.growthRate)).toList(),
                  isCurved: true,
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
}
