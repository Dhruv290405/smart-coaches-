import 'notification_model.dart';

class NotificationsResponse {
  final bool success;
  final String? message;
  final int? unreadCount;
  final List<NotificationModel> data;

  const NotificationsResponse({
    required this.success,
    this.message,
    this.unreadCount,
    required this.data,
  });

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final List<NotificationModel> notifications;

    if (rawData is List) {
      notifications = rawData
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      notifications = [];
    }

    return NotificationsResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      unreadCount: json['unreadCount'] as int?,
      data: notifications,
    );
  }
}
