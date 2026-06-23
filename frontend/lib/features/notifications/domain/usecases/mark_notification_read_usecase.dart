import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/notifications/domain/repositories/notification_repository.dart';

@injectable
class MarkNotificationReadUseCase {
  final NotificationRepository _repository;

  MarkNotificationReadUseCase(this._repository);

  Future<void> call(int notificationId) => _repository.markAsRead(notificationId);
}
