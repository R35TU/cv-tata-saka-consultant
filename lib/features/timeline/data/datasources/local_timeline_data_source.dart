import 'package:isar/isar.dart';
import '../../../../core/database/isar_database_service.dart';
import '../../../../core/database/isar_models.dart';
import '../models/timeline_model.dart';

abstract class TimelineLocalDataSource {
  Future<void> init();
  Future<List<TimelineModel>> getTimeline();
  Future<void> addTimeline(TimelineModel item);
  Future<void> seedTimeline();
}

class TimelineLocalDataSourceImpl implements TimelineLocalDataSource {
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
  Future<List<TimelineModel>> getTimeline() async {
    final database = await db;
    final list = await database.timelineIsars.where().findAll();
    return list.map((raw) => TimelineModel(
      id: raw.timelineId,
      title: raw.title,
      description: raw.description,
      user: raw.user,
      role: raw.role,
      icon: raw.icon,
      createdAt: raw.createdAt,
    )).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> addTimeline(TimelineModel item) async {
    final database = await db;
    await database.writeTxn(() async {
      final isarItem = TimelineIsar()
        ..timelineId = item.id
        ..projectId = ''
        ..title = item.title
        ..description = item.description
        ..user = item.user
        ..role = item.role
        ..icon = item.icon
        ..createdAt = item.createdAt;
      await database.timelineIsars.put(isarItem);
    });
  }

  @override
  Future<void> seedTimeline() async {
    // Already handled in IsarDatabaseService
  }
}
