import 'package:flutter/material.dart';
import '../pages/dashboard.dart';
import '../pages/insights.dart';
import '../pages/notifications.dart';
import '../pages/profile.dart';
import '../pages/settings.dart';

// This is a helper function that is designed for the BottomNavbar to navigate between widgets.
void navigateToPage(BuildContext context, int index, String latestState, BacterialGrowthController controller) {
  Widget page;

  switch (index) {
    case 0:
      page = DashboardPage(controller: controller);
      break;
    case 1:
      page = InsightsPage(
        controller: controller 
      );
      break;
    case 2:
      page = NotificationsPage();
      break;
    case 3:
      page = ProfilePage();
      break;
    case 4:
      page = SettingsPage();
      break;
    default:
      page = DashboardPage(controller: controller);
  }

  // The code below is to prevent unnecessary page reloads
  if (ModalRoute.of(context)?.settings.name != page.runtimeType.toString()) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}
