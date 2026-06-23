import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/core/network/rest_client.dart';
import 'package:smart_coach_new/core/network/safe_request.dart';
import 'package:smart_coach_new/features/notifications/data/models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications({int limit, int offset});
  Future<void> markAsRead(int notificationId);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(int notificationId);
}

@Injectable(as: NotificationRemoteDataSource)
class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final RestClient _restClient;

  NotificationRemoteDataSourceImpl(this._restClient);

  @override
  Future<List<NotificationModel>> getNotifications({
    int limit = 10,
    int offset = 0,
  }) async {
    final response = await safeRequest(
      () => _restClient.getNotifications(limit, offset),
    );
    return response.data;
  }

  @override
  Future<void> markAsRead(int notificationId) async {
    await safeRequest(() => _restClient.markNotificationAsRead(notificationId));
  }

  @override
  Future<void> markAllAsRead() async {
    await safeRequest(() => _restClient.markAllNotificationsAsRead());
  }

  @override
  Future<void> deleteNotification(int notificationId) async {
    await safeRequest(() => _restClient.deleteNotification(notificationId));
  }
}
