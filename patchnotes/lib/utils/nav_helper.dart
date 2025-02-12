import 'package:flutter/material.dart';
import '../views/dashboard.dart';
import '../views/insights.dart';
import '../views/notifications.dart';
import '../views/profile.dart';
import '../views/settings.dart';

// This is a helper function that is designed for the BottomNavbar to navigate between widgets.
void navigateToPage(BuildContext context, int index, String latestState) {
  Widget page;

  switch (index) {
    case 0:
      page = DashboardView();
      break;
    case 1:
      page = InsightsPage();
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
      page = DashboardView();
  }

  // The code below is to prevent unnecessary page reloads
  if (ModalRoute.of(context)?.settings.name != page.runtimeType.toString()) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}
