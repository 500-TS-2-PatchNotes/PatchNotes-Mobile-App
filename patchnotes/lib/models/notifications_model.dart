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
