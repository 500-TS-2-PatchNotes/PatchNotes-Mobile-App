import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Patch Notes',
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _navigateToPage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  final List<String> _titles = [
    'Dashboard',
    'Insights',
    'Notifications',
    'Settings',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DashboardPage(onNavigate: _navigateToPage),
      InsightsPage(
        currentState: BacterialGrowthController().currentState,
        lastSynced: DateTime.now(),
      ),
      const Center(
          child: Text('Notifications Page', style: TextStyle(fontSize: 24))),
      const Center(
          child: Text('Settings Page', style: TextStyle(fontSize: 24))),
      const Center(child: Text('Profile Page', style: TextStyle(fontSize: 24))),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF967BB6),
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          _navigateToPage(index);
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: _buildIcon(0, Icons.dashboard, 'Dashboard'),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(1, Icons.insights, 'Insights'),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(2, Icons.notifications, 'Notifications'),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(3, Icons.settings, 'Settings'),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(4, Icons.person, 'Profile'),
            label: '',
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(int index, IconData icon, String label) {
    final isSelected = index == _currentIndex;
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: isSelected ? Colors.purple : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.white : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Bacterial Growth Controller for Shared State
class BacterialGrowthController {
  static final BacterialGrowthController _instance =
      BacterialGrowthController._internal();

  factory BacterialGrowthController() => _instance;

  BacterialGrowthController._internal() {
    _startGraph();
  }

  final List<FlSpot> _dataPoints = [];
  double _currentTime = 0;
  String _currentState = 'Healthy';
  Timer? _timer;

  // ✅ Add StreamControllers
  final _dataStreamController = StreamController<List<FlSpot>>.broadcast();
  final _stateStreamController = StreamController<String>.broadcast();

  // ✅ Expose the streams
  Stream<List<FlSpot>> get dataStream => _dataStreamController.stream;
  Stream<String> get stateStream => _stateStreamController.stream;

  List<FlSpot> get dataPoints => _dataPoints;
  String get currentState => _currentState;

  void _startGraph() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final randomGrowth = Random().nextDouble() * 50; // Random growth value
      _dataPoints.add(FlSpot(_currentTime, randomGrowth));
      _currentTime += 1;

      _currentState = _getWoundState(randomGrowth);

      // Limit x-axis range to 30 seconds
      if (_dataPoints.length > 30) {
        _dataPoints.removeAt(0);
      }

      // ✅ Send updates to listeners
      _dataStreamController.add(List.from(_dataPoints));
      _stateStreamController.add(_currentState);
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


class DashboardPage extends StatelessWidget {
  final Function(int) onNavigate;

  const DashboardPage({required this.onNavigate, super.key});

  @override
  Widget build(BuildContext context) {
    final controller = BacterialGrowthController();

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
          height: 250, // Graph height
          child: StreamBuilder<List<FlSpot>>(
            stream: controller.dataStream,
            initialData: controller.dataPoints,
            builder: (context, snapshot) {
              return LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
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
                    rightTitles: AxisTitles(
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
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  minX: snapshot.data!.isNotEmpty ? snapshot.data!.first.x : 0,
                  maxX: snapshot.data!.isNotEmpty ? snapshot.data!.last.x + 30 : 30,
                  minY: 0,
                  maxY: 50,
                  lineBarsData: [
                    LineChartBarData(
                      spots: snapshot.data ?? [],
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [Colors.blue, Colors.green],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      barWidth: 3,
                      belowBarData: BarAreaData(show: false),
                      dotData: FlDotData(show: false),
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
                onNavigate(1); // Navigate to Insights Page
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF59ADC8),
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
                  fontWeight: FontWeight.bold, // Make the text bold
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF59ADC8),
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
                  fontWeight: FontWeight.bold, // Make the text bold
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
        return const Color(0xFFC8E6C9).withOpacity(0.8); // Soft green (light mint)
      case 'Observation':
        return const Color(0xFFFFF9C4).withOpacity(0.8); // Light pastel yellow
      case 'Early Infection':
        return const Color(0xFFFFCCBC).withOpacity(0.8); // Light peach-orange
      case 'Severe Infection':
        return const Color(0xFFEF9A9A).withOpacity(0.8); // Soft red (muted)
      case 'Critical':
        return const Color(0xFFD1C4E9).withOpacity(0.8); // Soft lavender purple
      default:
        return const Color(0xFFEEEEEE).withOpacity(0.8); // Neutral light grey
    }
  }
}


class InsightsPage extends StatelessWidget {
  final String currentState;
  final DateTime lastSynced;

  InsightsPage(
      {required this.currentState, required this.lastSynced, super.key});

  String _getStatusMessage(String state) {
    switch (state) {
      case 'Healthy':
        return 'Status: Your wound is healing well. Good Job!';
      case 'Observation':
        return 'Status: Your wound needs monitoring. Keep an eye on it!';
      case 'Early Infection':
        return 'Status: Your wound shows signs of infection. Take action!';
      case 'Severe Infection':
        return 'Status: Your wound is severely infected. Seek medical advice!';
      case 'Critical':
        return 'Status: Your wound is critical. Visit a healthcare provider immediately!';
      default:
        return 'Status: Unknown wound status.';
    }
  }

  String _getTip(String state) {
    switch (state) {
      case 'Healthy':
        return 'Tip: Keep the wound clean and moisturized.';
      case 'Observation':
        return 'Tip: Ensure the wound is properly dressed.';
      case 'Early Infection':
        return 'Tip: Clean the wound with an antiseptic and monitor it closely.';
      case 'Severe Infection':
        return 'Tip: Consult a healthcare professional for immediate attention.';
      case 'Critical':
        return 'Tip: Seek emergency medical care immediately!';
      default:
        return 'Tip: Unknown advice.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Image> woundImages = List.generate(
      10,
      (index) => Image.asset('assets/wound_sample.png', fit: BoxFit.cover),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status Message
        Container(
          padding: const EdgeInsets.all(16),
          color: Color(0xFFE6E6FA),
          child: Text(
            _getStatusMessage(currentState),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Title for Most Recent Wound Images
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Most Recent Wound Images',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),

        // Grid of Wound Images
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5, // 5 columns
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: woundImages.length,
            itemBuilder: (context, index) => Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: woundImages[index],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Tip Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getTip(currentState),
              style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Last Synced
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Last synced: ${_formatDateTime(lastSynced)}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatMonth(dateTime.month)} ${dateTime.day}, ${dateTime.year}, '
        '${_formatTime(dateTime)}';
  }

  String _formatMonth(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
