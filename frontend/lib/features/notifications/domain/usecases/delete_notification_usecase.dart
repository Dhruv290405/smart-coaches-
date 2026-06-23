import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/notifications/domain/repositories/notification_repository.dart';

@injectable
class DeleteNotificationUseCase {
  final NotificationRepository _repository;

  DeleteNotificationUseCase(this._repository);

  Future<void> call(int notificationId) =>
      _repository.deleteNotification(notificationId);
}
