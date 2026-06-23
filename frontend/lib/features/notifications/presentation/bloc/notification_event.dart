abstract class NotificationEvent {
  const NotificationEvent();
}

class LoadNotifications extends NotificationEvent {
  const LoadNotifications({this.limit = 10, this.offset = 0});
  final int limit;
  final int offset;
}

class MarkNotificationRead extends NotificationEvent {
  final int notificationId;
  const MarkNotificationRead(this.notificationId);
}

class MarkAllNotificationsRead extends NotificationEvent {
  const MarkAllNotificationsRead();
}

class DeleteNotification extends NotificationEvent {
  final int notificationId;
  const DeleteNotification(this.notificationId);
}

class FcmNotificationReceived extends NotificationEvent {
  final String title;
  final String body;
  final String type;

  const FcmNotificationReceived({
    required this.title,
    required this.body,
    required this.type,
  });
}
