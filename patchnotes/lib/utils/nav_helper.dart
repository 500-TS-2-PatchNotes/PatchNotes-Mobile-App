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
      page = InsightsView();
      break;
    case 2:
      page = NotificationsView();
      break;
    case 3:
      page = ProfileView();
      break;
    case 4:
      page = SettingsView();
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
