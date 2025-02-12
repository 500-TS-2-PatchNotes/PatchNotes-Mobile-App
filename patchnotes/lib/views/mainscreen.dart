import 'package:flutter/material.dart';
import 'package:patchnotes/viewmodels/bacterial_growth.dart';
import 'package:patchnotes/views/dashboard.dart';
import 'package:patchnotes/views/insights.dart';
import 'package:provider/provider.dart';
import '../widgets/bottom_navbar.dart';
import '../views/notifications.dart';
import '../views/profile.dart';
import '../views/settings.dart';

final GlobalKey<_MainScreenState> mainScreenKey = GlobalKey<_MainScreenState>();

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      DashboardView(),
      InsightsPage(),
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

  void reset() {
    setState(() {
      _currentIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final growthVM = Provider.of<BacterialGrowthViewModel>(context);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: _currentIndex,
        latestState: growthVM.currentState,
        onTabTapped: onTabTapped,
      ),
    );
  }
}
