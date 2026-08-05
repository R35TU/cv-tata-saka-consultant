import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/enums/app_role.dart';
import '../features/auth/data/models/user_model.dart';
import '../features/auth/presentation/auth_controller.dart';

// ═══════════════════════════════════════════════════════════════════════════
// MODEL – menu item
// ═══════════════════════════════════════════════════════════════════════════

class DrawerMenuItem {
  final String id;
  final String label;
  final IconData icon;
  final IconData? activeIcon;
  final Set<AppRole> roles; // empty = all roles

  const DrawerMenuItem({
    required this.id,
    required this.label,
    required this.icon,
    this.activeIcon,
    this.roles = const {},
  });
}

// ═══════════════════════════════════════════════════════════════════════════
// MENU CONFIGURATION per role
// ═══════════════════════════════════════════════════════════════════════════

class _MenuConfig {
  static const _all = <AppRole>{};

  static List<DrawerMenuItem> forRole(AppRole role) {
    final allMenus = <DrawerMenuItem>[
      // ── Dashboard (all)
      DrawerMenuItem(id: 'dashboard', label: 'Dashboard', icon: Icons.space_dashboard_outlined, activeIcon: Icons.space_dashboard, roles: _all),

      // ── KONSULTAN
      DrawerMenuItem(id: 'projects', label: 'Data Proyek', icon: Icons.folder_outlined, activeIcon: Icons.folder, roles: {AppRole.konsultan}),
      DrawerMenuItem(id: 'admin_project', label: 'Administrasi Proyek', icon: Icons.admin_panel_settings_outlined, activeIcon: Icons.admin_panel_settings, roles: {AppRole.konsultan}),
      DrawerMenuItem(id: 'laporan_kontraktor', label: 'Laporan Kontraktor', icon: Icons.assignment_outlined, activeIcon: Icons.assignment, roles: {AppRole.konsultan}),
      DrawerMenuItem(id: 'laporan_pengawasan', label: 'Laporan Pengawasan', icon: Icons.fact_check_outlined, activeIcon: Icons.fact_check, roles: {AppRole.konsultan}),
      DrawerMenuItem(id: 'timeline', label: 'Timeline', icon: Icons.timeline_outlined, activeIcon: Icons.timeline, roles: {AppRole.konsultan}),
      DrawerMenuItem(id: 'progress_monitoring', label: 'Progress Monitoring', icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, roles: {AppRole.konsultan}),
      DrawerMenuItem(id: 'rekap_laporan', label: 'Rekap Laporan', icon: Icons.summarize_outlined, activeIcon: Icons.summarize, roles: {AppRole.konsultan}),
      DrawerMenuItem(id: 'statistik', label: 'Statistik', icon: Icons.pie_chart_outline, activeIcon: Icons.pie_chart, roles: {AppRole.konsultan}),
      DrawerMenuItem(id: 'manajemen_user', label: 'Manajemen User', icon: Icons.group_outlined, activeIcon: Icons.group, roles: {AppRole.konsultan}),
      DrawerMenuItem(id: 'hak_akses', label: 'Hak Akses', icon: Icons.lock_outline, activeIcon: Icons.lock, roles: {AppRole.konsultan}),
      DrawerMenuItem(id: 'kelola_akun', label: 'Kelola Akun', icon: Icons.manage_accounts_outlined, activeIcon: Icons.manage_accounts, roles: {AppRole.konsultan}),

      // ── KONTRAKTOR
      DrawerMenuItem(id: 'projects', label: 'Proyek Saya', icon: Icons.folder_outlined, activeIcon: Icons.folder, roles: {AppRole.kontraktor}),
      DrawerMenuItem(id: 'laporan', label: 'Input Laporan Harian', icon: Icons.assignment_outlined, activeIcon: Icons.assignment, roles: {AppRole.kontraktor}),
      DrawerMenuItem(id: 'riwayat_laporan', label: 'Riwayat Laporan', icon: Icons.history_outlined, activeIcon: Icons.history, roles: {AppRole.kontraktor}),
      DrawerMenuItem(id: 'timeline', label: 'Timeline', icon: Icons.timeline_outlined, activeIcon: Icons.timeline, roles: {AppRole.kontraktor}),
      DrawerMenuItem(id: 'progress_project', label: 'Progress Proyek', icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, roles: {AppRole.kontraktor}),
      DrawerMenuItem(id: 'administrasi', label: 'Administrasi', icon: Icons.admin_panel_settings_outlined, activeIcon: Icons.admin_panel_settings, roles: {AppRole.kontraktor}),

      // ── DINAS
      DrawerMenuItem(id: 'projects', label: 'Monitoring Proyek', icon: Icons.folder_outlined, activeIcon: Icons.folder, roles: {AppRole.dinas}),
      DrawerMenuItem(id: 'progress', label: 'Progress', icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, roles: {AppRole.dinas}),
      DrawerMenuItem(id: 'timeline', label: 'Timeline', icon: Icons.timeline_outlined, activeIcon: Icons.timeline, roles: {AppRole.dinas}),
      DrawerMenuItem(id: 'laporan', label: 'Laporan', icon: Icons.assignment_outlined, activeIcon: Icons.assignment, roles: {AppRole.dinas}),
      DrawerMenuItem(id: 'statistik', label: 'Statistik', icon: Icons.pie_chart_outline, activeIcon: Icons.pie_chart, roles: {AppRole.dinas}),
      DrawerMenuItem(id: 'dokumentasi', label: 'Dokumentasi', icon: Icons.photo_library_outlined, activeIcon: Icons.photo_library, roles: {AppRole.dinas}),

      // ── EKSTERNAL
      DrawerMenuItem(id: 'projects', label: 'Proyek', icon: Icons.folder_outlined, activeIcon: Icons.folder, roles: {AppRole.eksternal}),
      DrawerMenuItem(id: 'progress', label: 'Progress', icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, roles: {AppRole.eksternal}),
      DrawerMenuItem(id: 'timeline', label: 'Timeline', icon: Icons.timeline_outlined, activeIcon: Icons.timeline, roles: {AppRole.eksternal}),
      DrawerMenuItem(id: 'dokumentasi', label: 'Dokumentasi', icon: Icons.photo_library_outlined, activeIcon: Icons.photo_library, roles: {AppRole.eksternal}),

      // ── ALL – bottom group
      DrawerMenuItem(id: 'notifications', label: 'Notifikasi', icon: Icons.notifications_outlined, activeIcon: Icons.notifications, roles: _all),
      DrawerMenuItem(id: 'profile', label: 'Profil', icon: Icons.person_outlined, activeIcon: Icons.person, roles: _all),
      DrawerMenuItem(id: 'settings', label: 'Pengaturan', icon: Icons.settings_outlined, activeIcon: Icons.settings, roles: _all),
    ];

    return allMenus.where((m) => m.roles.isEmpty || m.roles.contains(role)).toList();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// NAVIGATION helper
// ═══════════════════════════════════════════════════════════════════════════

typedef OnMenuTap = void Function(String menuId);

// ═══════════════════════════════════════════════════════════════════════════
// APP DRAWER  (main entry)
// ═══════════════════════════════════════════════════════════════════════════

class AppDrawer extends ConsumerWidget {
  final String activeMenuId;
  final OnMenuTap onMenuTap;

  const AppDrawer({
    super.key,
    required this.activeMenuId,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.valueOrNull;

    if (user == null) {
      return const Drawer(child: Center(child: CircularProgressIndicator()));
    }

    final role = user.role;
    final menuItems = _MenuConfig.forRole(role);
    final roleColor = _roleColor(role);

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.80,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // ── Header
          _DrawerHeader(user: user, roleColor: roleColor),

          // ── Menu list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              children: menuItems.map((item) {
                final isActive = item.id == activeMenuId;
                return _DrawerMenuTile(
                  item: item,
                  isActive: isActive,
                  roleColor: roleColor,
                  onTap: () {
                    Navigator.of(context).pop(); // close drawer
                    onMenuTap(item.id);
                  },
                );
              }).toList(),
            ),
          ),

          // ── Divider + Logout
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: Column(
              children: [
                const Divider(height: 1, color: Color(0xFFF0F1F5)),
                const SizedBox(height: 6),
                _DrawerMenuTile(
                  item: const DrawerMenuItem(
                    id: 'logout',
                    label: 'Logout',
                    icon: Icons.logout_rounded,
                    roles: {},
                  ),
                  isActive: false,
                  roleColor: const Color(0xFFE53935),
                  labelColor: const Color(0xFFE53935),
                  iconColor: const Color(0xFFE53935),
                  onTap: () => _confirmLogout(context, ref),
                ),
              ],
            ),
          ),

          // bottom safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Color _roleColor(AppRole role) => switch (role) {
        AppRole.konsultan => const Color(0xFF00C853),
        AppRole.kontraktor => const Color(0xFF001AFF),
        AppRole.dinas => const Color(0xFFFF3D00),
        AppRole.eksternal => const Color(0xFFAB47BC),
      };

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    Navigator.of(context).pop(); // close drawer first
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Konfirmasi Logout',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari aplikasi?',
          style: TextStyle(fontFamily: 'Inter', fontSize: 13.5, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal', style: TextStyle(fontFamily: 'Inter', color: Color(0xFF8E8E93))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Logout', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await ref.read(authControllerProvider.notifier).logout();
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DRAWER HEADER
// ═══════════════════════════════════════════════════════════════════════════

class _DrawerHeader extends ConsumerWidget {
  final UserModel user;
  final Color roleColor;

  const _DrawerHeader({required this.user, required this.roleColor});

  String _getInstansi(UserModel user) {
    if (user.role == AppRole.konsultan) {
      return 'CV. Tata Saka Consultant';
    } else if (user.role == AppRole.kontraktor) {
      if ((user.username?.contains('kontraktor2') ?? false) || user.name.contains('Koko')) {
        return 'PT. Koko Jaya Kontraktor';
      }
      return 'CV. Budi Kontraktor';
    } else if (user.role == AppRole.dinas) {
      return 'Dinas Pekerjaan Umum & PR';
    } else {
      return 'Masyarakat Umum / Eksternal';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Safe area at the top
    final topPad = MediaQuery.of(context).padding.top;
    final savedPhoto = ref.watch(profilePhotoProvider(user.id));

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPad + 24, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            roleColor.withValues(alpha: 0.12),
            roleColor.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + Online dot
          Stack(
            children: [
              _buildAvatar(savedPhoto),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 13,
                  height: 13,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Name
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1E1E),
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 4),

          // Role badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: roleColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user.role.label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: roleColor,
                fontFamily: 'Inter',
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Instansi
          Text(
            _getInstansi(user),
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF8E8E93),
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? savedPhoto) {
    if (savedPhoto != null && savedPhoto.isNotEmpty) {
      if (savedPhoto.startsWith('/') || savedPhoto.startsWith('file://')) {
        return CircleAvatar(
          radius: 34,
          backgroundImage: FileImage(File(savedPhoto.replaceFirst('file://', ''))),
          backgroundColor: const Color(0xFFD9D9D9),
        );
      }
      return CircleAvatar(
        radius: 34,
        backgroundImage: NetworkImage(savedPhoto),
        backgroundColor: const Color(0xFFD9D9D9),
      );
    }

    return CircleAvatar(
      radius: 34,
      backgroundColor: roleColor.withValues(alpha: 0.15),
      child: Icon(Icons.person, size: 38, color: roleColor),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DRAWER MENU TILE
// ═══════════════════════════════════════════════════════════════════════════

class _DrawerMenuTile extends StatelessWidget {
  final DrawerMenuItem item;
  final bool isActive;
  final Color roleColor;
  final Color? labelColor;
  final Color? iconColor;
  final VoidCallback onTap;

  const _DrawerMenuTile({
    required this.item,
    required this.isActive,
    required this.roleColor,
    required this.onTap,
    this.labelColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveIconColor = iconColor ?? (isActive ? roleColor : const Color(0xFF6B7280));
    final Color effectiveLabelColor = labelColor ?? (isActive ? roleColor : const Color(0xFF374151));
    final IconData icon = isActive && item.activeIcon != null ? item.activeIcon! : item.icon;

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: isActive ? roleColor.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        dense: true,
        visualDensity: const VisualDensity(vertical: -1),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        leading: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive ? roleColor.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 20, color: effectiveIconColor),
        ),
        title: Text(
          item.label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: effectiveLabelColor,
            fontFamily: 'Inter',
          ),
        ),
        trailing: isActive
            ? Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: roleColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              )
            : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
