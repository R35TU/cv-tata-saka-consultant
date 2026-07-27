import '../datasources/local_timeline_data_source.dart';
import '../models/timeline_model.dart';

abstract class TimelineRepository {
  Future<void> init();
  Future<List<TimelineModel>> getTimeline();
  Future<void> addTimeline(TimelineModel item);
}

class TimelineRepositoryImpl implements TimelineRepository {
  final TimelineLocalDataSource localDataSource;

  TimelineRepositoryImpl(this.localDataSource);

  @override
  Future<void> init() => localDataSource.init();

  @override
  Future<List<TimelineModel>> getTimeline() => localDataSource.getTimeline();

  @override
  Future<void> addTimeline(TimelineModel item) => localDataSource.addTimeline(item);
}
