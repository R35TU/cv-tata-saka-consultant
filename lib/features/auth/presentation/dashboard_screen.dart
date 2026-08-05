import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/enums/app_role.dart';
import '../../../widgets/stat_card.dart';
import '../../../widgets/progress_item.dart';
import '../../../widgets/dashboard_chart.dart';
import '../../../widgets/app_drawer.dart';
import '../../projects/presentation/project_controller.dart';
import '../../notifications/presentation/notification_controller.dart';
import '../../timeline/presentation/timeline_controller.dart';
import '../../reports/presentation/report_controller.dart';
import 'auth_controller.dart';
import '../../projects/presentation/project_list_screen.dart';
import '../../reports/presentation/report_screen.dart';
import '../../timeline/presentation/timeline_screen.dart';
import '../../reports/presentation/pending_approvals_screen.dart';
import 'edit_profile_screen.dart';
import 'security_screen.dart';
import 'settings_screen.dart';
import 'account_management_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Active drawer menu id — mirrors current bottom nav tab
  String get _activeDrawerMenuId {
    switch (_currentIndex) {
      case 0: return 'dashboard';
      case 1: return 'projects';
      case 2: return 'laporan';
      case 3: return 'timeline';
      case 4: return 'profile';
      default: return 'dashboard';
    }
  }

  void _onDrawerMenuTap(String menuId) {
    switch (menuId) {
      case 'dashboard': setState(() => _currentIndex = 0);
      case 'projects': setState(() => _currentIndex = 1);
      case 'laporan':
      case 'laporan_kontraktor':
      case 'laporan_pengawasan':
      case 'riwayat_laporan': setState(() => _currentIndex = 2);
      case 'timeline':
      case 'progress_monitoring':
      case 'progress_project':
      case 'progress': setState(() => _currentIndex = 3);
      case 'profile':
      case 'administrasi':
      case 'admin_project':
      case 'rekap_laporan':
      case 'statistik':
      case 'manajemen_user':
      case 'hak_akses':
      case 'dokumentasi': setState(() => _currentIndex = 4);
      case 'kelola_akun':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AccountManagementScreen()));
      case 'settings':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
      case 'notifications':
        context.push('/notifications');
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(projectsControllerProvider.notifier).loadProjects();
      ref.read(notificationsControllerProvider.notifier).loadNotifications();
      ref.read(timelineControllerProvider.notifier).loadTimeline();
      ref.read(contractorReportsProvider.notifier).loadReports();
      ref.read(supervisorReportsProvider.notifier).loadReports();
      ref.read(authControllerProvider.notifier).initialize();
    });
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Daftar Proyek';
      case 2:
        return 'Laporan Proyek';
      case 3:
        return 'Kronologi Proyek';
      case 4:
        return 'Akun';
      default:
        return 'Dashboard';
    }
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return const ProjectListScreen();
      case 2:
        return const ReportScreen();
      case 3:
        return const TimelineScreen();
      case 4:
        return _buildAccountTab();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildAccountTab() {
    final authState = ref.watch(authControllerProvider);
    final projectsState = ref.watch(projectsControllerProvider);
    final user = authState.valueOrNull;
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final projects = projectsState.valueOrNull ?? [];

    // Role color mappings
    final Color roleColor = switch (user.role) {
      AppRole.konsultan => const Color(0xFF00C853),
      AppRole.kontraktor => const Color(0xFF001AFF),
      AppRole.dinas => const Color(0xFFFF3D00),
      AppRole.eksternal => const Color(0xFFAB47BC),
    };

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Avatar + Name ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Stack(
                  children: [
                    Consumer(
                      builder: (context, ref, child) {
                        final savedPhoto = ref.watch(profilePhotoProvider(user.id));
                        if (savedPhoto != null && savedPhoto.isNotEmpty) {
                          return CircleAvatar(
                            radius: 38,
                            backgroundImage: FileImage(File(savedPhoto)),
                            backgroundColor: const Color(0xFFD9D9D9),
                          );
                        }
                        return CircleAvatar(
                          radius: 38,
                          backgroundColor: const Color(0xFFD9D9D9),
                          child: Icon(Icons.person, size: 44, color: Colors.white.withValues(alpha: 0.8)),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: const Color(0xFF001AFF),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, size: 13, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E), fontFamily: 'Inter'),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.role.label,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF8E8E93), fontFamily: 'Inter'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Informasi Profil ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Informasi Profil',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E), fontFamily: 'Inter'),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
            ),
            child: Column(
              children: [
                _buildInfoRow(Icons.person_outline, 'Nama Lengkap', user.name),
                const Divider(height: 1, color: Color(0xFFF0F1F5), indent: 16, endIndent: 16),
                _buildInfoRow(Icons.badge_outlined, 'Username', user.username ?? '-'),
                const Divider(height: 1, color: Color(0xFFF0F1F5), indent: 16, endIndent: 16),
                _buildInfoRow(Icons.admin_panel_settings_outlined, 'Role', user.role.label),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Proyek Terkait ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Proyek Terkait',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E), fontFamily: 'Inter'),
            ),
          ),
          const SizedBox(height: 10),
          if (projects.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
                ),
                child: const Center(
                  child: Text('Belum ada proyek terkait.', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.grey)),
                ),
              ),
            )
          else
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
              ),
              child: Column(
                children: projects.take(4).toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final project = entry.value;
                  final isLast = index == (projects.length > 4 ? 3 : projects.length - 1);
                  final isProgres = project.status == 'Progres';
                  final statusColor = isProgres ? const Color(0xFF00C853) : const Color(0xFF001AFF);
                  final statusLabel = isProgres ? 'Progres' : 'Selesai';
                  final statusIcon = isProgres ? Icons.autorenew_rounded : Icons.check_circle_rounded;

                  return Column(
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => setState(() => _currentIndex = 1),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Row(
                            children: [
                              // Project thumbnail
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: () {
                                  final url = project.imageUrl;
                                  if (url.isEmpty) return _buildProjectImagePlaceholder(roleColor);
                                  if (url.startsWith('/') || url.startsWith('file://')) {
                                    return Image.file(
                                      File(url.replaceFirst('file://', '')),
                                      width: 54, height: 54, fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => _buildProjectImagePlaceholder(roleColor),
                                    );
                                  }
                                  return Image.network(
                                    url,
                                    width: 54, height: 54, fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _buildProjectImagePlaceholder(roleColor),
                                  );
                                }(),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      project.name,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E1E1E), fontFamily: 'Inter'),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(statusIcon, size: 11, color: statusColor),
                                          const SizedBox(width: 4),
                                          Text(
                                            statusLabel,
                                            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: statusColor, fontFamily: 'Inter'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (!isLast) const Divider(height: 1, color: Color(0xFFF0F1F5), indent: 16, endIndent: 16),
                    ],
                  );
                }).toList(),
              ),
            ),

          const SizedBox(height: 24),

          // ── Menu Lainnya ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Menu Lainnya',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E), fontFamily: 'Inter'),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
            ),
            child: Column(
              children: [
                _buildMenuRow(
                  icon: Icons.settings_outlined,
                  title: 'Pengaturan',
                  subtitle: 'Notifikasi, Tema, dan lainnya',
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
                ),
                const Divider(height: 1, color: Color(0xFFF0F1F5), indent: 16, endIndent: 16),
                _buildMenuRow(
                  icon: Icons.security_outlined,
                  title: 'Keamanan',
                  subtitle: 'Password, login & aktivitas',
                  onTap: () {
                    final user = ref.read(authControllerProvider).valueOrNull;
                    if (user != null) {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => SecurityScreen(user: user)));
                    }
                  },
                ),
                const Divider(height: 1, color: Color(0xFFF0F1F5), indent: 16, endIndent: 16),
                _buildMenuRow(
                  icon: Icons.help_outline_rounded,
                  title: 'Bantuan & FAQ',
                  subtitle: 'Pusat bantuan dan pertanyaan',
                  onTap: () => _showMockDialog('Bantuan & FAQ', 'Sistem Monitoring Konstruksi mendukung pengelolaan data offline secara penuh.'),
                ),
                const Divider(height: 1, color: Color(0xFFF0F1F5), indent: 16, endIndent: 16),
                _buildMenuRow(
                  icon: Icons.info_outline_rounded,
                  title: 'Info Aplikasi',
                  subtitle: 'Versi 1.0.0',
                  showChevron: false,
                  onTap: () => _showMockDialog('Info Aplikasi', 'Sistem Informasi Monitoring Pengawasan Proyek Konstruksi v1.0.0 (Local First Enterprise Edition).'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Keluar Akun ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await ref.read(authControllerProvider.notifier).logout();
                },
                icon: const Icon(Icons.logout_rounded, color: Color(0xFFFF3D00), size: 20),
                label: const Text('Keluar Akun', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFFF3D00), fontFamily: 'Inter')),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFF3D00), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 19, color: const Color(0xFF8E8E93)),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF1E1E1E), fontFamily: 'Inter')),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 13, color: Color(0xFF8E8E93), fontFamily: 'Inter')),
        ],
      ),
    );
  }

  Widget _buildMenuRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showChevron = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: const Color(0xFF4A4A4A)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF1E1E1E), fontFamily: 'Inter')),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 11.5, color: Color(0xFF8E8E93), fontFamily: 'Inter')),
                ],
              ),
            ),
            if (showChevron)
              const Icon(Icons.chevron_right, size: 20, color: Color(0xFFB0B3BE)),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectImagePlaceholder(Color color) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.business_center_outlined, size: 24, color: color.withValues(alpha: 0.5)),
    );
  }



  void _showMockDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text(message, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, height: 1.4)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Tutup', style: TextStyle(color: Color(0xFF001AFF), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    final authState = ref.watch(authControllerProvider);
    final statsState = ref.watch(dashboardStatsProvider);
    final projectsState = ref.watch(projectsControllerProvider);
    final timelineState = ref.watch(timelineControllerProvider);

    final user = authState.valueOrNull;
    final userName = user?.name ?? 'User';
    final userRole = user?.role ?? AppRole.eksternal;
    final roleLabel = userRole.label;

    final rawProjects = projectsState.valueOrNull ?? [];
    final projects = rawProjects; 

    final timeline = timelineState.valueOrNull ?? [];

    return statsState.when(
      loading: () => const Center(child: Padding(
        padding: EdgeInsets.all(40.0),
        child: CircularProgressIndicator(),
      )),
      error: (err, st) => Center(child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Text('Gagal memuat statistik: $err'),
      )),
      data: (stats) {
        final totalProjects = stats['totalProjects'] ?? 0;
        final activeProjects = stats['activeProjects'] ?? 0;
        final completedProjects = stats['completedProjects'] ?? 0;
        final totalReports = stats['totalReports'] ?? 0;
        final pendingReports = stats['pendingReports'] ?? 0;
        final rejectedReports = stats['rejectedReports'] ?? 0;
        // Note: avgProgress and avgFinancialProgress are computed inside DashboardChart

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Selamat Datang,', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF757575), fontFamily: 'Inter')),
                const SizedBox(height: 4),
                Text(userName, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E), fontFamily: 'Inter')),
                const SizedBox(height: 2),
                Text(roleLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFA0A0A0), fontFamily: 'Inter')),
                const SizedBox(height: 24),
                
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.35,
                  children: [
                    StatCard(
                      title: 'Total Proyek',
                      value: totalProjects.toString(),
                      icon: Icons.folder,
                      iconColor: const Color(0xFF001AFF),
                      iconBackgroundColor: const Color(0xFFE5EAFF),
                      onTap: () => setState(() => _currentIndex = 1),
                    ),
                    StatCard(
                      title: 'Proyek Aktif',
                      value: activeProjects.toString(),
                      icon: Icons.bar_chart_rounded,
                      iconColor: const Color(0xFF00C853),
                      iconBackgroundColor: const Color(0xFFE8F9EE),
                      onTap: () => setState(() => _currentIndex = 1),
                    ),
                    StatCard(
                      title: 'Proyek Selesai',
                      value: completedProjects.toString(),
                      icon: Icons.check_box_rounded,
                      iconColor: const Color(0xFF001AFF),
                      iconBackgroundColor: const Color(0xFFE5EAFF),
                      onTap: () => setState(() => _currentIndex = 1),
                    ),
                    StatCard(
                      title: 'Laporan Menunggu',
                      value: pendingReports.toString(),
                      icon: Icons.hourglass_empty_rounded,
                      iconColor: const Color(0xFFFF9100),
                      iconBackgroundColor: const Color(0xFFFFF4E5),
                      onTap: () {
                        if (userRole == AppRole.konsultan) {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const PendingApprovalsScreen()),
                          );
                        } else {
                          setState(() => _currentIndex = 2);
                        }
                      },
                    ),
                    StatCard(
                      title: 'Laporan Ditolak',
                      value: rejectedReports.toString(),
                      icon: Icons.cancel_outlined,
                      iconColor: const Color(0xFFFF3D00),
                      iconBackgroundColor: const Color(0xFFFFECE5),
                      onTap: () => setState(() => _currentIndex = 2),
                    ),
                    StatCard(
                      title: 'Total Laporan',
                      value: totalReports.toString(),
                      icon: Icons.description_rounded,
                      iconColor: const Color(0xFFAB47BC),
                      iconBackgroundColor: const Color(0xFFF3E5F5),
                      onTap: () => setState(() => _currentIndex = 2),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                const SizedBox(height: 28),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Proyek On Progress', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: Color(0xFF1E1E1E), fontFamily: 'Inter')),
                    TextButton(onPressed: () => setState(() => _currentIndex = 1), child: const Text('Lihat Semua', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF001AFF), fontFamily: 'Inter'))),
                  ],
                ),
                const SizedBox(height: 12),
                if (projects.isEmpty)
                  const Center(child: Text('Belum ada data proyek.', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.grey)))
                else
                  ...projects.take(3).map((project) => ProgressItem(title: project.name, progress: project.physicalProgress, progressColor: const Color(0xFF00C853))),
            
            const SizedBox(height: 28),
            DashboardChart(projects: projects, userRole: userRole),
            
            const SizedBox(height: 28),
            const Text('Aktivitas Terkini', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: Color(0xFF1E1E1E), fontFamily: 'Inter')),
            const SizedBox(height: 12),
            if (timeline.isEmpty)
              const Center(child: Text('Belum ada riwayat aktivitas.', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.grey)))
            else
              ...timeline.take(3).map((item) => Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Color(0xFFF0F1F5))),
                    color: Colors.white,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFE5EAFF),
                        child: Icon(
                          item.icon == 'report' ? Icons.description_rounded : item.icon == 'folder' ? Icons.folder_rounded : Icons.check_circle_rounded,
                          color: const Color(0xFF001AFF),
                          size: 20,
                        ),
                      ),
                      title: Text(item.title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E), fontFamily: 'Inter')),
                      subtitle: Text('${item.description}\nOleh: ${item.user} (${item.role})', style: const TextStyle(fontSize: 11, color: Color(0xFF757575), fontFamily: 'Inter', height: 1.4)),
                      trailing: Text(item.createdAt.length > 10 ? item.createdAt.substring(11) : item.createdAt, style: const TextStyle(fontSize: 10, color: Color(0xFFA0A0A0), fontFamily: 'Inter')),
                      isThreeLine: true,
                    ),
                  )),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final notificationsState = ref.watch(notificationsControllerProvider);
    final notifications = notificationsState.valueOrNull ?? [];
    final unreadCount = notifications.where((n) => !n.isRead).length;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: AppDrawer(
        activeMenuId: _activeDrawerMenuId,
        onMenuTap: _onDrawerMenuTap,
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1.0), child: Container(color: const Color(0xFFF0F1F5), height: 1.0)),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF1E1E1E), size: 28),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(_getAppBarTitle(), style: const TextStyle(color: Color(0xFF1E1E1E), fontWeight: FontWeight.w700, fontSize: 16.5, fontFamily: 'Inter')),
        centerTitle: true,
        actions: [
          if (_currentIndex == 4) ...([
            // Edit profile icon for Akun tab
            Builder(builder: (ctx) {
              final authState = ref.watch(authControllerProvider);
              final user = authState.valueOrNull;
              return IconButton(
                icon: const Icon(Icons.edit_outlined, color: Color(0xFF1E1E1E), size: 24),
                onPressed: user == null
                    ? null
                    : () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => EditProfileScreen(user: user)),
                        ),
                tooltip: 'Edit Profil',
              );
            }),
          ]) else ...[
            // Notification icon for other tabs
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_outlined, color: Color(0xFF1E1E1E), size: 26),
                  onPressed: () => context.push('/notifications'),
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                      child: Text(
                        unreadCount.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFF0F1F5), width: 1.0))),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF001AFF),
          unselectedItemColor: const Color(0xFFB0B3BE),
          selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
          unselectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, fontFamily: 'Inter'),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.folder_outlined), label: 'Proyek'),
            BottomNavigationBarItem(icon: Icon(Icons.description_outlined), label: 'Laporan'),
            BottomNavigationBarItem(icon: Icon(Icons.timeline_outlined), label: 'Timeline'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Akun')
          ],
        ),
      ),
    );
  }
}
