import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patchnotes/viewmodels/notifications_viewmodel.dart';
import '../widgets/top_navbar.dart';

class NotificationsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notificationsVM = Provider.of<NotificationsViewModel>(context);

    return Scaffold(
      appBar: const Header(title: "Notifications"),
      body: notificationsVM.notifications.isEmpty
          ? const Center(child: Text('No notifications'))
          : ListView.builder(
              itemCount: notificationsVM.notifications.length,
              itemBuilder: (context, index) {
                final item = notificationsVM.notifications[index];

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
                      notificationsVM.markAsSeen(index);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('"${item.title}" marked as seen')),
                      );
                      return false; // Prevent dismissal
                    } else if (direction == DismissDirection.endToStart) {
                      return true;
                    }
                    return false;
                  },
                  onDismissed: (direction) {
                    if (direction == DismissDirection.endToStart) {
                      notificationsVM.removeNotification(index);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notification dismissed')),
                      );
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
                          notificationsVM.markAsSeen(index);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('"${item.title}" marked as seen')),
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
