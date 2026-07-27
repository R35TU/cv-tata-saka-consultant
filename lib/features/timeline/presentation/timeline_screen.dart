import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../widgets/timeline_item.dart';
import 'timeline_controller.dart';

class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(timelineControllerProvider.notifier).loadTimeline());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(timelineControllerProvider);
    return state.when(
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timeline, size: 48, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                const Text(
                  'Belum ada data kronologi.',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          physics: const BouncingScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            
            // Extract date and time from createdAt (yyyy-MM-dd HH:mm)
            final parts = item.createdAt.split(' ');
            final dateStr = parts.isNotEmpty ? parts.first : item.createdAt;
            final timeStr = parts.length > 1 ? parts.last : '';

            return TimelineItem(
              date: dateStr,
              time: timeStr,
              description: '${item.title}: ${item.description}',
              actor: '${item.user} (${item.role})',
              isLast: index == items.length - 1,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(error.toString(), style: const TextStyle(fontFamily: 'Inter'))),
    );
  }
}
