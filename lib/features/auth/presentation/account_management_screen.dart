import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/isar_database_service.dart';
import '../../../../core/database/isar_models.dart';
import '../../../../core/enums/app_role.dart';
import '../data/models/user_model.dart';
import 'auth_controller.dart';
import '../../projects/presentation/project_controller.dart';

// ── Provider: all users (refreshable) ───────────────────────────────────────
final allUsersListProvider = FutureProvider.autoDispose<List<UserModel>>((ref) async {
  final isar = await IsarDatabaseService.db;
  final rawList = await isar.userIsars.where().findAll();
  return rawList.map((u) => UserModel(
    id: u.userId,
    name: u.name,
    username: u.username,
    password: u.password,
    role: AppRole.fromString(u.role),
    email: u.email,
    phone: u.phone,
    isActive: u.isActive,
  )).toList();
});

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class AccountManagementScreen extends ConsumerStatefulWidget {
  const AccountManagementScreen({super.key});

  @override
  ConsumerState<AccountManagementScreen> createState() => _AccountManagementScreenState();
}

class _AccountManagementScreenState extends ConsumerState<AccountManagementScreen> {
  // Role color helpers
  Color _roleColor(AppRole role) => switch (role) {
    AppRole.konsultan  => const Color(0xFF00C853),
    AppRole.kontraktor => const Color(0xFF001AFF),
    AppRole.dinas      => const Color(0xFFFF3D00),
    AppRole.eksternal  => const Color(0xFFAB47BC),
  };

  IconData _roleIcon(AppRole role) => switch (role) {
    AppRole.konsultan  => Icons.engineering_outlined,
    AppRole.kontraktor => Icons.construction_outlined,
    AppRole.dinas      => Icons.account_balance_outlined,
    AppRole.eksternal  => Icons.person_outline,
  };

  // ── Refresh ─────────────────────────────────────────────────────────────
  void _refresh() => ref.invalidate(allUsersListProvider);

  // ── Add User Dialog ──────────────────────────────────────────────────────
  void _showAddUserDialog() {
    final nameCtrl     = TextEditingController();
    final usernameCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final emailCtrl    = TextEditingController();
    final phoneCtrl    = TextEditingController();
    AppRole selectedRole = AppRole.kontraktor;
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.person_add_alt_1_outlined, color: Color(0xFF001AFF), size: 22),
              SizedBox(width: 10),
              Text('Tambah Akun', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _dialogField(nameCtrl, 'Nama Lengkap', Icons.person_outline),
                const SizedBox(height: 12),
                _dialogField(usernameCtrl, 'Username', Icons.alternate_email),
                const SizedBox(height: 12),
                _dialogField(passwordCtrl, 'Password', Icons.lock_outline, obscure: true),
                const SizedBox(height: 12),
                _dialogField(emailCtrl, 'Email (opsional)', Icons.email_outlined),
                const SizedBox(height: 12),
                _dialogField(phoneCtrl, 'No. HP (opsional)', Icons.phone_outlined),
                const SizedBox(height: 16),
                const Text('Role', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<AppRole>(
                      isExpanded: true,
                      value: selectedRole,
                      items: AppRole.values.map((r) => DropdownMenuItem(
                        value: r,
                        child: Row(
                          children: [
                            Icon(_roleIcon(r), size: 16, color: _roleColor(r)),
                            const SizedBox(width: 8),
                            Text(r.label, style: const TextStyle(fontFamily: 'Inter', fontSize: 13)),
                          ],
                        ),
                      )).toList(),
                      onChanged: (v) => setDialogState(() => selectedRole = v!),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.of(ctx).pop(),
              child: const Text('Batal', style: TextStyle(color: Color(0xFF8E8E93))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF001AFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: isLoading ? null : () async {
                if (nameCtrl.text.trim().isEmpty || usernameCtrl.text.trim().isEmpty || passwordCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nama, username, dan password wajib diisi.')),
                  );
                  return;
                }
                setDialogState(() => isLoading = true);
                try {
                  final newUser = UserModel(
                    id: const Uuid().v4(),
                    name: nameCtrl.text.trim(),
                    username: usernameCtrl.text.trim(),
                    password: passwordCtrl.text.trim(), // hashed in data source
                    role: selectedRole,
                    email: emailCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    isActive: true,
                  );
                  await ref.read(authRepositoryProvider).addUser(newUser);
                  if (ctx.mounted) Navigator.of(ctx).pop();
                  _refresh();
                  ref.invalidate(allUsersProvider);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Akun "${nameCtrl.text.trim()}" berhasil ditambahkan.')),
                    );
                  }
                } catch (e) {
                  setDialogState(() => isLoading = false);
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: isLoading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Simpan', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Edit User Dialog ─────────────────────────────────────────────────────
  void _showEditUserDialog(UserModel user) {
    final nameCtrl  = TextEditingController(text: user.name);
    final emailCtrl = TextEditingController(text: user.email);
    final phoneCtrl = TextEditingController(text: user.phone);
    AppRole selectedRole = user.role;
    bool isActive = user.isActive;
    bool isLoading = false;

    // Prevent editing the konsultan's own role
    final currentUser = ref.read(authControllerProvider).valueOrNull;
    final isSelf = currentUser?.id == user.id;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(_roleIcon(user.role), color: _roleColor(user.role), size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Edit Akun', style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.alternate_email, size: 14, color: Color(0xFF8E8E93)),
                      const SizedBox(width: 6),
                      Text('@${user.username}', style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFF8E8E93))),
                      const Spacer(),
                      const Text('(tidak bisa diubah)', style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: Color(0xFFB0B3BE))),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _dialogField(nameCtrl, 'Nama Lengkap', Icons.person_outline),
                const SizedBox(height: 12),
                _dialogField(emailCtrl, 'Email', Icons.email_outlined),
                const SizedBox(height: 12),
                _dialogField(phoneCtrl, 'No. HP', Icons.phone_outlined),
                if (!isSelf) ...[
                  const SizedBox(height: 16),
                  const Text('Role', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<AppRole>(
                        isExpanded: true,
                        value: selectedRole,
                        items: AppRole.values.map((r) => DropdownMenuItem(
                          value: r,
                          child: Row(
                            children: [
                              Icon(_roleIcon(r), size: 16, color: _roleColor(r)),
                              const SizedBox(width: 8),
                              Text(r.label, style: const TextStyle(fontFamily: 'Inter', fontSize: 13)),
                            ],
                          ),
                        )).toList(),
                        onChanged: (v) => setDialogState(() => selectedRole = v!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Status Aktif', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500)),
                      Switch(
                        value: isActive,
                        onChanged: (v) => setDialogState(() => isActive = v),
                        activeColor: const Color(0xFF00C853),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.of(ctx).pop(),
              child: const Text('Batal', style: TextStyle(color: Color(0xFF8E8E93))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF001AFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: isLoading ? null : () async {
                setDialogState(() => isLoading = true);
                try {
                  final updated = user.copyWith(
                    name: nameCtrl.text.trim(),
                    role: isSelf ? user.role : selectedRole,
                    email: emailCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    isActive: isSelf ? user.isActive : isActive,
                  );
                  await ref.read(authRepositoryProvider).updateUser(updated);
                  if (ctx.mounted) Navigator.of(ctx).pop();
                  _refresh();
                  ref.invalidate(allUsersProvider);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Akun "${updated.name}" berhasil diperbarui.')),
                    );
                  }
                } catch (e) {
                  setDialogState(() => isLoading = false);
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: isLoading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Simpan', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Reset Password Dialog ─────────────────────────────────────────────────
  void _showResetPasswordDialog(UserModel user) {
    final newPwdCtrl = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Reset Password', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reset password untuk akun @${user.username}', style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFF8E8E93))),
              const SizedBox(height: 12),
              _dialogField(newPwdCtrl, 'Password Baru', Icons.lock_outline, obscure: true),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Batal', style: TextStyle(color: Color(0xFF8E8E93)))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9100),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: isLoading ? null : () async {
                if (newPwdCtrl.text.trim().isEmpty) return;
                setDialogState(() => isLoading = true);
                try {
                  await ref.read(authRepositoryProvider).resetUserPassword(user.id, newPwdCtrl.text.trim());
                  if (ctx.mounted) Navigator.of(ctx).pop();
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password @${user.username} berhasil direset.')));
                } catch (e) {
                  setDialogState(() => isLoading = false);
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: isLoading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Reset', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Show Project Relations ────────────────────────────────────────────────
  void _showProjectRelationsDialog(UserModel user) async {
    final isar = await IsarDatabaseService.db;
    final members = await isar.contractMemberIsars.filter().userIdEqualTo(user.id).findAll();
    final allProjects = await isar.contractIsars.where().findAll();

    if (!mounted) return;

    final relatedProjects = members.map((m) {
      final proj = allProjects.firstWhere((p) => p.contractId == m.contractId, orElse: () => throw Exception());
      return {'name': proj.name, 'role': m.role, 'status': proj.status};
    }).toList();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(_roleIcon(user.role), size: 20, color: _roleColor(user.role)),
            const SizedBox(width: 8),
            Expanded(child: Text('Proyek — ${user.name}', style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 15))),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: relatedProjects.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Belum terdaftar di proyek manapun.', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFF8E8E93))),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: relatedProjects.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF0F1F5)),
                  itemBuilder: (context, index) {
                    final proj = relatedProjects[index];
                    final isProgres = proj['status'] == 'Progres';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isProgres ? const Color(0xFFE8F9EE) : const Color(0xFFE5EAFF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              isProgres ? Icons.autorenew_rounded : Icons.check_circle_rounded,
                              size: 18,
                              color: isProgres ? const Color(0xFF00C853) : const Color(0xFF001AFF),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(proj['name']!, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E1E1E))),
                                const SizedBox(height: 2),
                                Text('Jabatan: ${proj['role']}', style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: Color(0xFF8E8E93))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Tutup', style: TextStyle(color: Color(0xFF001AFF), fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _dialogField(TextEditingController ctrl, String label, IconData icon, {bool obscure = false}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      style: const TextStyle(fontFamily: 'Inter', fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFF6B7280)),
        prefixIcon: Icon(icon, size: 18, color: const Color(0xFF8E8E93)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF001AFF), width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersListProvider);
    final currentUser = ref.watch(authControllerProvider).valueOrNull;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFF0F1F5), height: 1),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E1E1E)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Kelola Akun',
          style: TextStyle(color: Color(0xFF1E1E1E), fontWeight: FontWeight.w700, fontSize: 16.5, fontFamily: 'Inter'),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF1E1E1E)),
            onPressed: _refresh,
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddUserDialog,
        backgroundColor: const Color(0xFF001AFF),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
        label: const Text('Tambah Akun', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 13)),
      ),
      body: usersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (users) {
          if (users.isEmpty) {
            return const Center(child: Text('Tidak ada akun.', style: TextStyle(fontFamily: 'Inter', color: Color(0xFF8E8E93))));
          }

          // Group by role
          final grouped = <AppRole, List<UserModel>>{};
          for (final r in AppRole.values) {
            final g = users.where((u) => u.role == r).toList();
            if (g.isNotEmpty) grouped[r] = g;
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              // ── Summary chips ──────────────────────────────────────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: AppRole.values.map((r) {
                    final count = users.where((u) => u.role == r).length;
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _roleColor(r).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _roleColor(r).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_roleIcon(r), size: 13, color: _roleColor(r)),
                          const SizedBox(width: 5),
                          Text('${r.label} ($count)', style: TextStyle(fontFamily: 'Inter', fontSize: 11.5, fontWeight: FontWeight.w600, color: _roleColor(r))),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // ── User list grouped by role ──────────────────────────────
              ...grouped.entries.map((entry) {
                final role = entry.key;
                final roleUsers = entry.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(_roleIcon(role), size: 14, color: _roleColor(role)),
                          const SizedBox(width: 6),
                          Text(role.label, style: TextStyle(fontFamily: 'Inter', fontSize: 12.5, fontWeight: FontWeight.bold, color: _roleColor(role))),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE8E8E8)),
                      ),
                      child: Column(
                        children: roleUsers.asMap().entries.map((e) {
                          final idx = e.key;
                          final user = e.value;
                          final isSelf = currentUser?.id == user.id;
                          return Column(
                            children: [
                              _buildUserTile(user, isSelf: isSelf, roleColor: _roleColor(role)),
                              if (idx < roleUsers.length - 1)
                                const Divider(height: 1, color: Color(0xFFF0F1F5), indent: 16, endIndent: 16),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUserTile(UserModel user, {required bool isSelf, required Color roleColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: roleColor.withValues(alpha: 0.12),
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 15, color: roleColor),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.name,
                        style: const TextStyle(fontFamily: 'Inter', fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF1E1E1E)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isSelf) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF001AFF).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Anda', style: TextStyle(fontFamily: 'Inter', fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF001AFF))),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text('@${user.username}', style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: Color(0xFF8E8E93))),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(
                        color: user.isActive ? const Color(0xFF00C853) : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      user.isActive ? 'Aktif' : 'Nonaktif',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 10.5, color: user.isActive ? const Color(0xFF00C853) : Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Actions menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF8E8E93), size: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (action) {
              switch (action) {
                case 'edit': _showEditUserDialog(user);
                case 'reset_pwd': _showResetPasswordDialog(user);
                case 'projects': _showProjectRelationsDialog(user);
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 16, color: Color(0xFF4A4A4A)), SizedBox(width: 10), Text('Edit Akun', style: TextStyle(fontFamily: 'Inter', fontSize: 13))])),
              const PopupMenuItem(value: 'reset_pwd', child: Row(children: [Icon(Icons.lock_reset_outlined, size: 16, color: Color(0xFFFF9100)), SizedBox(width: 10), Text('Reset Password', style: TextStyle(fontFamily: 'Inter', fontSize: 13))])),
              const PopupMenuItem(value: 'projects', child: Row(children: [Icon(Icons.folder_outlined, size: 16, color: Color(0xFF001AFF)), SizedBox(width: 10), Text('Keterkaitan Proyek', style: TextStyle(fontFamily: 'Inter', fontSize: 13))])),
            ],
          ),
        ],
      ),
    );
  }
}
