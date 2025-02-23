import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patchnotes/providers/bg_provider.dart';
import 'package:patchnotes/providers/navigation.dart';
import 'package:patchnotes/views/dashboard.dart';
import 'package:patchnotes/views/insights.dart';
import 'package:patchnotes/views/notifications.dart';
import 'package:patchnotes/views/profile.dart';
import 'package:patchnotes/views/settings.dart';
import '../widgets/bottom_navbar.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int currentIndex = ref.watch(tabIndexProvider); 
    final growthState = ref.watch(bacterialGrowthProvider);

    final List<Widget> pages = [
      DashboardView(),
      InsightsView(),
      NotificationsView(),
      ProfileView(),
      SettingsView(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: currentIndex,
        latestState: growthState.currentState,
        onTabTapped: (index) => ref.read(tabIndexProvider.notifier).state = index, // ✅ Update tab state
      ),
    );
  }
}
