import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patchnotes/providers/user_provider.dart';
import '../widgets/top_navbar.dart';

class NotificationsView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(userProvider).account?.notifications ?? [];

    return Scaffold(
      appBar: const Header(title: "Notifications"),
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
                      ref.read(userProvider.notifier).markNotificationAsSeen(index);
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
                      ref.read(userProvider.notifier).removeNotification(index);
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
                          ref.read(userProvider.notifier).markNotificationAsSeen(index);
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
