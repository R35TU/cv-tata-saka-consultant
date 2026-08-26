import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_model.dart';
import 'auth_controller.dart';

class SecurityScreen extends ConsumerStatefulWidget {
  final UserModel user;
  const SecurityScreen({super.key, required this.user});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  final _currentPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;
  bool _isSaving = false;

  // Password strength flags (live-update based on _newPassCtrl)
  bool get _hasLength => _newPassCtrl.text.length >= 8;
  bool get _hasUpperLower =>
      _newPassCtrl.text.contains(RegExp(r'[A-Z]')) &&
      _newPassCtrl.text.contains(RegExp(r'[a-z]'));
  bool get _hasNumber => _newPassCtrl.text.contains(RegExp(r'[0-9]'));
  bool get _hasSymbol => _newPassCtrl.text.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));

  // Mock login activity
  final List<Map<String, String>> _loginActivity = [
    {'device': 'iPhone 11', 'icon': 'phone', 'location': 'Jakarta, Indonesia', 'time': '01 Januari 2025 10:30 WIB'},
    {'device': 'Windows - Brave', 'icon': 'desktop', 'location': 'Semarang, Indonesia', 'time': '25 November 2024 17:23 WIB'},
  ];

  @override
  void initState() {
    super.initState();
    _newPassCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final current = _currentPassCtrl.text;
    final newPass = _newPassCtrl.text;
    final confirm = _confirmPassCtrl.text;

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      _showSnack('Semua field password harus diisi', isError: true);
      return;
    }
    if (!_hasLength || !_hasUpperLower || !_hasNumber || !_hasSymbol) {
      _showSnack('Password baru tidak memenuhi syarat keamanan', isError: true);
      return;
    }
    if (newPass != confirm) {
      _showSnack('Konfirmasi password tidak sesuai', isError: true);
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref.read(authControllerProvider.notifier).changePassword(widget.user.id, current, newPass);
      _currentPassCtrl.clear();
      _newPassCtrl.clear();
      _confirmPassCtrl.clear();
      _showSnack('Password berhasil diubah', isError: false);
    } catch (e) {
      _showSnack(e.toString().replaceAll('Exception: ', ''), isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Inter')),
        backgroundColor: isError ? const Color(0xFFFF3D00) : const Color(0xFF00C853),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1, color: Color(0xFFF0F1F5)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E1E1E)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Keamanan',
          style: TextStyle(color: Color(0xFF1E1E1E), fontWeight: FontWeight.w700, fontSize: 16.5, fontFamily: 'Inter'),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Ubah Password ──────────────────────────────────
            const Text(
              'Ubah Password',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E), fontFamily: 'Inter'),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8E8E8)),
              ),
              child: Column(
                children: [
                  _buildPasswordField(
                    label: 'Password Saat ini',
                    hint: 'Masukkan password saat ini',
                    controller: _currentPassCtrl,
                    obscure: !_showCurrent,
                    onToggle: () => setState(() => _showCurrent = !_showCurrent),
                    isFirst: true,
                    isLast: false,
                  ),
                  const Divider(height: 1, color: Color(0xFFF0F1F5)),
                  _buildPasswordField(
                    label: 'Password Baru',
                    hint: 'Masukkan password baru',
                    controller: _newPassCtrl,
                    obscure: !_showNew,
                    onToggle: () => setState(() => _showNew = !_showNew),
                    isFirst: false,
                    isLast: false,
                  ),
                  const Divider(height: 1, color: Color(0xFFF0F1F5)),
                  _buildPasswordField(
                    label: 'Konfirmasi Password Baru',
                    hint: 'Masukkan kembali password baru',
                    controller: _confirmPassCtrl,
                    obscure: !_showConfirm,
                    onToggle: () => setState(() => _showConfirm = !_showConfirm),
                    isFirst: false,
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Syarat Password ────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF4FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Syarat Password',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E), fontFamily: 'Inter'),
                  ),
                  const SizedBox(height: 8),
                  _buildRequirement('Minimal 8 Karakter', _hasLength),
                  const SizedBox(height: 4),
                  _buildRequirement('Mengandung huruf besar dan kecil', _hasUpperLower),
                  const SizedBox(height: 4),
                  _buildRequirement('Mengandung angka', _hasNumber),
                  const SizedBox(height: 4),
                  _buildRequirement('Mengandung simbol', _hasSymbol),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Save password button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF001AFF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Simpan Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
              ),
            ),

            const SizedBox(height: 28),

            // ── Aktivitas Login Terakhir ───────────────────────
            const Text(
              'Aktivitas Login Terakhir',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E), fontFamily: 'Inter'),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8E8E8)),
              ),
              child: Column(
                children: [
                  ..._loginActivity.asMap().entries.map((entry) {
                    final i = entry.key;
                    final item = entry.value;
                    final isLast = i == _loginActivity.length - 1;
                    final isPhone = item['icon'] == 'phone';
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  isPhone ? Icons.phone_android_rounded : Icons.desktop_windows_outlined,
                                  size: 20,
                                  color: const Color(0xFF4A4A4A),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['device']!, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF1E1E1E), fontFamily: 'Inter')),
                                    const SizedBox(height: 2),
                                    Text(item['location']!, style: const TextStyle(fontSize: 11.5, color: Color(0xFF8E8E93), fontFamily: 'Inter')),
                                    const SizedBox(height: 1),
                                    Text(item['time']!, style: const TextStyle(fontSize: 11, color: Color(0xFFB0B3BE), fontFamily: 'Inter')),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isLast) const Divider(height: 1, color: Color(0xFFF0F1F5), indent: 16, endIndent: 16),
                      ],
                    );
                  }),

                  const Divider(height: 1, color: Color(0xFFF0F1F5)),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fitur lihat semua aktivitas akan segera hadir (v2.0).')),
                      );
                    },
                    child: const Text(
                      'Lihat Semua Aktivitas',
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF001AFF), fontFamily: 'Inter'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Keluar Dari Semua Perangkat ────────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Keluar Dari Semua Perangkat', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 15)),
                      content: const Text('Anda akan keluar dari semua perangkat yang aktif. Lanjutkan?', style: TextStyle(fontFamily: 'Inter', fontSize: 13, height: 1.4)),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Batal')),
                        TextButton(
                          onPressed: () async {
                            Navigator.of(ctx).pop();
                            await ref.read(authControllerProvider.notifier).logout();
                          },
                          child: const Text('Keluar', style: TextStyle(color: Color(0xFFFF3D00), fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.logout_rounded, color: Color(0xFFFF3D00), size: 18),
                label: const Text('Keluar Dari Semua Perangkat', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFFFF3D00), fontFamily: 'Inter')),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFF3D00), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
    required bool isFirst,
    required bool isLast,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11.5, color: Color(0xFF8E8E93), fontFamily: 'Inter')),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscure,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF1E1E1E), fontFamily: 'Inter'),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(fontSize: 13.5, color: Color(0xFFB0B3BE), fontFamily: 'Inter'),
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onToggle,
                child: Icon(
                  obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 20,
                  color: const Color(0xFF8E8E93),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRequirement(String text, bool met) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: met ? const Color(0xFF00C853) : const Color(0xFFE0E0E0),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, size: 12, color: Colors.white),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12.5,
            color: met ? const Color(0xFF1E1E1E) : const Color(0xFF8E8E93),
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}
