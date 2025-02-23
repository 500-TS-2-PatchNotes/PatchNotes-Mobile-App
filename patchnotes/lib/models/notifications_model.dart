class NotificationItem {
  final String id;
  final String title;
  final String message;
  final bool seen; 

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    this.seen = false,
  });

  factory NotificationItem.fromMap(Map<String, dynamic> data) {
    return NotificationItem(
      id: data['id'] ?? '',
      title: data['title'] ?? 'No Title',
      message: data['message'] ?? 'No Message',
      seen: data['seen'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "id": id,
      "title": title,
      "message": message,
      "seen": seen,
    };
  }

  /// **🛠 Copy Method for Updating State**
  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    bool? seen,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      seen: seen ?? this.seen,
    );
  }

  @override
  String toString() {
    return 'NotificationItem(id: $id, title: $title, message: $message, seen: $seen)';
  }
}
