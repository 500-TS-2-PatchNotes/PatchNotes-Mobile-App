import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<NotificationItem> notifications = [
    NotificationItem(
        id: '1', title: 'Welcome!', message: 'Thanks for signing up.'),
    NotificationItem(
        id: '2',
        title: 'Update Available',
        message: 'A new update is ready to install.'),
    NotificationItem(
        id: '3',
        title: 'Reminder',
        message: 'Make sure to check for any color changes on your wound.'),
  ];

  void _markAsSeen(int index) {
    setState(() {
      notifications[index].seen = true;
    });
  }

  void _removeNotification(int index) {
    setState(() {
      notifications.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Notification dismissed')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: notifications.isEmpty
          ? const Center(child: Text('No notifications'))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final item = notifications[index];
                return Dismissible(
                  key: Key(item.id),
                  background: Container(
                    color: Colors.green,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: const Icon(Icons.check, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.redAccent,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      // Swipe right: mark as seen and cancel dismissal.
                      _markAsSeen(index);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('"${item.title}" marked as seen')),
                      );
                      return false; // Prevent the dismissal removal.
                    } else if (direction == DismissDirection.endToStart) {
                      // Swipe left: allow dismissal (removal).
                      return true;
                    }
                    return false;
                  },
                  onDismissed: (direction) {
                    // This callback is only called if confirmDismiss returns true.
                    if (direction == DismissDirection.endToStart) {
                      _removeNotification(index);
                    }
                  },
                  child: Card(
                    color: item.seen ? Colors.grey.shade300 : Colors.white,
                    child: ListTile(
                      title: Text(item.title),
                      subtitle: Text(item.message),
                      trailing: TextButton(
                        child: const Text('Mark as Seen'),
                        onPressed: () {
                          _markAsSeen(index);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('"${item.title}" marked as seen')),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  bool seen;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    this.seen = false,
  });
}
