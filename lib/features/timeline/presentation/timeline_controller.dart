import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/local_timeline_data_source.dart';
import '../data/repositories/timeline_repository.dart';
import '../data/models/timeline_model.dart';

final timelineRepositoryProvider = Provider<TimelineRepository>((ref) {
  return TimelineRepositoryImpl(TimelineLocalDataSourceImpl());
});

final timelineControllerProvider = StateNotifierProvider<TimelineController, AsyncValue<List<TimelineModel>>>((ref) {
  final repository = ref.watch(timelineRepositoryProvider);
  return TimelineController(repository);
});

class TimelineController extends StateNotifier<AsyncValue<List<TimelineModel>>> {
  final TimelineRepository _repository;

  TimelineController(this._repository) : super(const AsyncValue.data([]));

  Future<void> loadTimeline() async {
    state = const AsyncValue.loading();
    try {
      await _repository.init();
      final timeline = await _repository.getTimeline();
      state = AsyncValue.data(timeline);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
