import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:patchnotes/settings.dart';
import 'package:patchnotes/testImage.dart';
import 'dashboard.dart';
import 'insights.dart';
import 'firebase_options.dart';
import 'login.dart';
import 'notifications.dart';
import 'profile.dart';

//Image Storage
final storage = FirebaseStorage
    .instance; //- Firebase Storage that is used to store wound images

//Database
FirebaseFirestore firestore =
    FirebaseFirestore.instance; //- Firestore stores information

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Patch Notes',
      home: LoginPageMobile(),
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
        initialState: BacterialGrowthController().currentState,
        initialLastSynced: DateTime.now(),
      ),
      NotificationsPage(),
      ProfilePage(),
      SettingsPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF967BB6),
        automaticallyImplyLeading: false,
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
            icon: _buildIcon(3, Icons.person, 'Profile'),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(4, Icons.settings, 'Settings'),
            label: '',
          )
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
