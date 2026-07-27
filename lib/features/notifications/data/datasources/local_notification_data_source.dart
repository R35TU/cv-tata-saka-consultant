import 'package:isar/isar.dart';
import '../../../../core/database/isar_database_service.dart';
import '../../../../core/database/isar_models.dart';
import '../models/notification_model.dart';

abstract class NotificationLocalDataSource {
  Future<void> init();
  Future<List<NotificationModel>> getNotifications();
  Future<void> addNotification(NotificationModel item);
  Future<void> markAsRead(String id);
  Future<void> seedNotifications();
}

class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  Isar? _db;

  Future<Isar> get db async {
    if (_db != null) return _db!;
    _db = await IsarDatabaseService.db;
    return _db!;
  }

  @override
  Future<void> init() async {
    await db;
  }

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final database = await db;
    final list = await database.notificationIsars.where().findAll();
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
    final database = await db;
    await database.writeTxn(() async {
      final isarNotif = NotificationIsar()
        ..notificationId = item.id
        ..title = item.title
        ..message = item.message
        ..type = item.type
        ..isRead = item.isRead
        ..createdAt = item.createdAt;
      await database.notificationIsars.put(isarNotif);
    });
  }

  @override
  Future<void> markAsRead(String id) async {
    final database = await db;
    final existing = await database.notificationIsars.filter().notificationIdEqualTo(id).findFirst();
    if (existing != null) {
      await database.writeTxn(() async {
        existing.isRead = true;
        await database.notificationIsars.put(existing);
      });
    }
  }

  @override
  Future<void> seedNotifications() async {
    // Already handled in IsarDatabaseService
  }
}
