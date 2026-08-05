import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/database/hive_database_service.dart';
import '../../../../core/database/hive_models.dart';
import '../models/notification_model.dart';

abstract class NotificationLocalDataSource {
  Future<void> init();
  Future<List<NotificationModel>> getNotifications();
  Future<void> addNotification(NotificationModel item);
  Future<void> markAsRead(String id);
  Future<void> seedNotifications();
}

class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  @override
  Future<void> init() async {
    await HiveDatabaseService.initDb();
  }

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final box = Hive.box<NotificationHive>('notifications');
    final list = box.values.toList();
    return list.map((raw) => NotificationModel(
      id: raw.notificationId,
      title: raw.title,
      message: raw.message,
      type: raw.type,
      isRead: raw.isRead,
      createdAt: raw.createdAt,
    )).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> addNotification(NotificationModel item) async {
    final box = Hive.box<NotificationHive>('notifications');
    final hiveNotif = NotificationHive()
      ..notificationId = item.id
      ..title = item.title
      ..message = item.message
      ..type = item.type
      ..isRead = item.isRead
      ..createdAt = item.createdAt;
    await box.put(item.id, hiveNotif);
  }

  @override
  Future<void> markAsRead(String id) async {
    final box = Hive.box<NotificationHive>('notifications');
    final existing = box.get(id);
    if (existing != null) {
      existing.isRead = true;
      await existing.save();
    }
  }

  @override
  Future<void> seedNotifications() async {}
}
