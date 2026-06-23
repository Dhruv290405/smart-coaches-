import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/notifications/domain/repositories/notification_repository.dart';

@injectable
class MarkAllNotificationsReadUseCase {
  final NotificationRepository _repository;

  MarkAllNotificationsReadUseCase(this._repository);

  Future<void> call() => _repository.markAllAsRead();
}
