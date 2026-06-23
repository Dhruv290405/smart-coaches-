import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:smart_coach_new/features/notifications/data/models/notification_model.dart';
import 'notification_repository.dart';

@Injectable(as: NotificationRepository)
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;

  NotificationRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<NotificationModel>> getNotifications({
    int limit = 10,
    int offset = 0,
  }) {
    return _remoteDataSource.getNotifications(limit: limit, offset: offset);
  }

  @override
  Future<void> markAsRead(int notificationId) {
    return _remoteDataSource.markAsRead(notificationId);
  }

  @override
  Future<void> markAllAsRead() {
    return _remoteDataSource.markAllAsRead();
  }

  @override
  Future<void> deleteNotification(int notificationId) {
    return _remoteDataSource.deleteNotification(notificationId);
  }
}
