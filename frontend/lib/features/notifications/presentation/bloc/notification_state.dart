import 'package:smart_coach_new/features/notifications/data/models/notification_model.dart';

abstract class NotificationState {
  const NotificationState();
}

class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

class NotificationLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;

  const NotificationLoaded({
    required this.notifications,
    required this.unreadCount,
  });

  NotificationLoaded copyWith({
    List<NotificationModel>? notifications,
  }) {
    final updated = notifications ?? this.notifications;
    return NotificationLoaded(
      notifications: updated,
      unreadCount: updated.where((n) => !n.isRead).length,
    );
  }
}

class NotificationFailure extends NotificationState {
  final String message;
  const NotificationFailure(this.message);
}
