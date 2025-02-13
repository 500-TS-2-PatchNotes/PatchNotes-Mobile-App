import 'package:flutter/material.dart';
import '../models/notifications_model.dart';

class NotificationsViewModel extends ChangeNotifier {
  final List<NotificationItem> _notifications = [
    NotificationItem(id: '1', title: 'Welcome!', message: 'Thanks for signing up.'),
    NotificationItem(id: '2', title: 'Update Available', message: 'A new update is ready to install.'),
    NotificationItem(id: '3', title: 'Reminder', message: 'Make sure to check for any color changes on your wound.'),
  ];

  List<NotificationItem> get notifications => _notifications;

  void markAsSeen(int index) {
    _notifications[index].seen = true;
    notifyListeners();
  }

  void removeNotification(int index) {
    _notifications.removeAt(index);
    notifyListeners();
  }
}
