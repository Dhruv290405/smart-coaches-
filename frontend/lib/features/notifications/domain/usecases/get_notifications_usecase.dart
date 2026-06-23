import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/notifications/data/models/notification_model.dart';
import 'package:smart_coach_new/features/notifications/domain/repositories/notification_repository.dart';

@injectable
class GetNotificationsUseCase {
  final NotificationRepository _repository;

  GetNotificationsUseCase(this._repository);

  Future<List<NotificationModel>> call({int limit = 10, int offset = 0}) {
    return _repository.getNotifications(limit: limit, offset: offset);
  }
}
