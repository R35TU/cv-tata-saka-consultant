import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/local_notification_data_source.dart';
import '../data/repositories/notification_repository.dart';
import '../data/models/notification_model.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(NotificationLocalDataSourceImpl());
});

final notificationsControllerProvider = StateNotifierProvider<NotificationsController, AsyncValue<List<NotificationModel>>>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return NotificationsController(repository);
});

class NotificationsController extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  final NotificationRepository _repository;

  NotificationsController(this._repository) : super(const AsyncValue.data([]));

  Future<void> loadNotifications() async {
    state = const AsyncValue.loading();
    try {
      await _repository.init();
      final notifications = await _repository.getNotifications();
      state = AsyncValue.data(notifications);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _repository.markAsRead(id);
      final list = state.valueOrNull ?? [];
      final updated = list.map((item) => item.id == id ? item.copyWith(isRead: true) : item).toList();
      state = AsyncValue.data(updated);
    } catch (error) {
      // Fail silently or log
    }
  }
}
