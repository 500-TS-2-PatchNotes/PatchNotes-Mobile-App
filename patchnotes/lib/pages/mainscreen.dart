import 'package:flutter/material.dart';
import 'package:patchnotes/widgets/bottom_navbar.dart';
import 'package:patchnotes/pages/dashboard.dart';
import 'package:patchnotes/pages/insights.dart';
import 'package:patchnotes/pages/notifications.dart';
import 'package:patchnotes/pages/profile.dart';
import 'package:patchnotes/pages/settings.dart';

// ignore: library_private_types_in_public_api
final GlobalKey<_MainScreenState> mainScreenKey = GlobalKey<_MainScreenState>(); // Global Key so that pages can navigate to other pages when they click a button.

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final BacterialGrowthController _growthController = BacterialGrowthController();
  
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState(); // This is required for Flutter state management

    _pages = [
      DashboardPage(controller: _growthController),
      InsightsPage(
        controller: _growthController,
      ),
      NotificationsPage(),
      ProfilePage(),
      SettingsPage(),
    ];
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex, // This prevents reloading of pages
        children: _pages,
      ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: _currentIndex,
        controller: _growthController,
        latestState: _growthController.currentState,
        onTabTapped: onTabTapped, // This will update the selected tab
      ),
    );
  }
}
