import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patchnotes/providers/navigation.dart';
import 'package:patchnotes/views/dashboard.dart';
import 'package:patchnotes/views/insights.dart';
import 'package:patchnotes/views/profile.dart';
import 'package:patchnotes/views/settings.dart';
import '../widgets/bottom_navbar.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  bool _didInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInit) {
      Future.microtask(() {
        final initialIndex =
            ModalRoute.of(context)?.settings.arguments as int? ?? 0;
        ref.read(tabIndexProvider.notifier).state = initialIndex;
      });
      _didInit = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(tabIndexProvider);

    final List<Widget> pages = [
      const DashboardView(),
      InsightsView(),
      const ProfileView(),
      SettingsView(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: currentIndex,
        onTabTapped: (index) =>
            ref.read(tabIndexProvider.notifier).state = index,
      ),
    );
  }
}
