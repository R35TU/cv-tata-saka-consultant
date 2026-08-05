import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/database/hive_database_service.dart';
import '../../../../core/database/hive_models.dart';
import '../models/timeline_model.dart';

abstract class TimelineLocalDataSource {
  Future<void> init();
  Future<List<TimelineModel>> getTimeline();
  Future<void> addTimeline(TimelineModel item);
  Future<void> seedTimeline();
}

class TimelineLocalDataSourceImpl implements TimelineLocalDataSource {
  @override
  Future<void> init() async {
    await HiveDatabaseService.initDb();
  }

  @override
  Future<List<TimelineModel>> getTimeline() async {
    final box = Hive.box<TimelineHive>('timelines');
    final list = box.values.toList();
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
    final box = Hive.box<TimelineHive>('timelines');
    final hiveItem = TimelineHive()
      ..timelineId = item.id
      ..projectId = ''
      ..title = item.title
      ..description = item.description
      ..user = item.user
      ..role = item.role
      ..icon = item.icon
      ..createdAt = item.createdAt;
    await box.put(item.id, hiveItem);
  }

  @override
  Future<void> seedTimeline() async {}
}
