import '../datasources/local_notification_data_source.dart';
import '../models/notification_model.dart';

abstract class NotificationRepository {
  Future<void> init();
  Future<List<NotificationModel>> getNotifications();
  Future<void> addNotification(NotificationModel item);
  Future<void> markAsRead(String id);
}

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationLocalDataSource localDataSource;

  NotificationRepositoryImpl(this.localDataSource);

  @override
  Future<void> init() => localDataSource.init();

  @override
  Future<List<NotificationModel>> getNotifications() => localDataSource.getNotifications();

  @override
  Future<void> addNotification(NotificationModel item) => localDataSource.addNotification(item);

  @override
  Future<void> markAsRead(String id) => localDataSource.markAsRead(id);
}
