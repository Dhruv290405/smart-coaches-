import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/notifications/data/models/notification_model.dart';
import 'package:smart_coach_new/features/notifications/domain/usecases/delete_notification_usecase.dart';
import 'package:smart_coach_new/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:smart_coach_new/features/notifications/domain/usecases/mark_all_notifications_read_usecase.dart';
import 'package:smart_coach_new/features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import 'notification_event.dart';
import 'notification_state.dart';

@injectable
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase _getNotifications;
  final MarkNotificationReadUseCase _markAsRead;
  final MarkAllNotificationsReadUseCase _markAllAsRead;
  final DeleteNotificationUseCase _deleteNotification;

  NotificationBloc(
    this._getNotifications,
    this._markAsRead,
    this._markAllAsRead,
    this._deleteNotification,
  ) : super(const NotificationInitial()) {
    on<LoadNotifications>(_onLoad);
    on<MarkNotificationRead>(_onMarkAsRead);
    on<MarkAllNotificationsRead>(_onMarkAllAsRead);
    on<DeleteNotification>(_onDelete);
    on<FcmNotificationReceived>(_onFcmReceived);
  }

  Future<void> _onLoad(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());
    try {
      final notifications = await _getNotifications(
        limit: event.limit,
        offset: event.offset,
      );
      emit(NotificationLoaded(
        notifications: notifications,
        unreadCount: notifications.where((n) => !n.isRead).length,
      ));
    } catch (e) {
      emit(NotificationFailure(e.toString()));
    }
  }

  Future<void> _onMarkAsRead(
    MarkNotificationRead event,
    Emitter<NotificationState> emit,
  ) async {
    final current = state;
    if (current is! NotificationLoaded) return;

    final updated = current.notifications.map((n) {
      return n.id == event.notificationId ? n.copyWith(isRead: true) : n;
    }).toList();

    emit(current.copyWith(notifications: updated));

    try {
      await _markAsRead(event.notificationId);
    } catch (_) {
      emit(current);
    }
  }

  Future<void> _onMarkAllAsRead(
    MarkAllNotificationsRead event,
    Emitter<NotificationState> emit,
  ) async {
    final current = state;
    if (current is! NotificationLoaded) return;

    final updated = current.notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();

    emit(current.copyWith(notifications: updated));

    try {
      await _markAllAsRead();
    } catch (_) {
      emit(current);
    }
  }

  Future<void> _onDelete(
    DeleteNotification event,
    Emitter<NotificationState> emit,
  ) async {
    final current = state;
    if (current is! NotificationLoaded) return;

    final updated = current.notifications
        .where((n) => n.id != event.notificationId)
        .toList();

    emit(current.copyWith(notifications: updated));

    try {
      await _deleteNotification(event.notificationId);
    } catch (_) {
      emit(current);
    }
  }

  void _onFcmReceived(
    FcmNotificationReceived event,
    Emitter<NotificationState> emit,
  ) {
    final current = state;

    final incoming = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch,
      title: event.title,
      body: event.body,
      isRead: false,
      type: event.type,
      createdAt: DateTime.now().toIso8601String(),
    );

    if (current is NotificationLoaded) {
      final updated = [incoming, ...current.notifications];
      emit(current.copyWith(notifications: updated));
    } else {
      emit(NotificationLoaded(
        notifications: [incoming],
        unreadCount: 1,
      ));
    }
  }
}
