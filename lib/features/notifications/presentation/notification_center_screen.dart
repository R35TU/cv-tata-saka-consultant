import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'notification_controller.dart';

class NotificationCenterScreen extends ConsumerStatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  ConsumerState<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends ConsumerState<NotificationCenterScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(notificationsControllerProvider.notifier).loadNotifications());
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'Approval':
        return Icons.verified_user_outlined;
      case 'Revisi':
        return Icons.edit_note_rounded;
      case 'Laporan Baru':
        return Icons.description_outlined;
      case 'Dokumen Baru':
        return Icons.folder_open_rounded;
      case 'Timeline Baru':
        return Icons.history_rounded;
      default:
        return Icons.notifications_none_outlined;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'Approval':
        return const Color(0xFF001AFF); // Blue
      case 'Revisi':
        return const Color(0xFFFF3D00); // Red
      case 'Laporan Baru':
        return const Color(0xFFFF9100); // Orange
      case 'Dokumen Baru':
        return const Color(0xFF00C853); // Green
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFF0F1F5), height: 1.0),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E1E1E), size: 24),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            color: Color(0xFF1E1E1E),
            fontWeight: FontWeight.w700,
            fontSize: 16.5,
            fontFamily: 'Inter',
          ),
        ),
        centerTitle: true,
      ),
      body: state.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  const Text(
                    'Tidak ada notifikasi masuk.',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final iconColor = _getColorForType(item.type);
              final iconBg = iconColor.withValues(alpha: 0.1);

              return GestureDetector(
                onTap: () {
                  ref.read(notificationsControllerProvider.notifier).markAsRead(item.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Notifikasi ditandai dibaca: ${item.title}'),
                      duration: const Duration(milliseconds: 800),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: item.isRead ? Colors.white : const Color(0xFFE5EAFF).withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: item.isRead ? const Color(0xFFF0F1F5) : const Color(0xFFB3C0FF),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: iconBg,
                        radius: 20,
                        child: Icon(_getIconForType(item.type), color: iconColor, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item.title,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: item.isRead ? const Color(0xFF333333) : const Color(0xFF001AFF),
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                if (!item.isRead)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(color: Color(0xFF001AFF), shape: BoxShape.circle),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.message,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF555555),
                                fontFamily: 'Inter',
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.createdAt,
                              style: const TextStyle(fontSize: 10, color: Colors.grey, fontFamily: 'Inter'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(error.toString(), style: const TextStyle(fontFamily: 'Inter')),
        ),
      ),
    );
  }
}
