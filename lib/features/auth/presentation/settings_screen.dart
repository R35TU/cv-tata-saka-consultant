import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ── State ──────────────────────────────────────────────────
  String _selectedTheme = 'Terang';
  String _selectedLanguage = 'Indonesia';

  bool _pushNotif = true;
  bool _emailNotif = true;
  bool _projectNotif = true;
  bool _reportNotif = true;

  String _reminderTime = '17:00';
  String _lastBackup = '31 Des 2025  10:30';
  double _cacheSize = 45.2;

  // ── Helpers ────────────────────────────────────────────────
  void _pickTheme() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _OptionSheet(
        title: 'Tema Aplikasi',
        options: const ['Terang', 'Gelap', 'Mengikuti Sistem'],
        selected: _selectedTheme,
        onSelect: (v) => setState(() => _selectedTheme = v),
      ),
    );
  }

  void _pickLanguage() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _OptionSheet(
        title: 'Bahasa Aplikasi',
        options: const ['Indonesia', 'English'],
        selected: _selectedLanguage,
        onSelect: (v) => setState(() => _selectedLanguage = v),
      ),
    );
  }

  Future<void> _pickReminderTime() async {
    final parts = _reminderTime.split(':');
    final initial = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null && mounted) {
      setState(() {
        _reminderTime =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  void _doBackup() {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final label =
        '${now.day} ${months[now.month - 1]} ${now.year}  ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    setState(() => _lastBackup = label);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Backup data berhasil'), backgroundColor: Color(0xFF00C853)),
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bersihkan Cache', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 15)),
        content: Text(
          'Hapus cache sebesar ${_cacheSize.toStringAsFixed(1)} MB?',
          style: const TextStyle(fontFamily: 'Inter', fontSize: 13),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() => _cacheSize = 0.0);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache berhasil dibersihkan'), backgroundColor: Color(0xFF00C853)),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Color(0xFFFF3D00), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────
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
          'Pengaturan',
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
            // ── Preferensi Aplikasi ────────────────────────────
            _sectionTitle('Preferensi Aplikasi'),
            const SizedBox(height: 10),
            _card(children: [
              _prefRow(
                icon: Icons.wb_sunny_rounded,
                iconBg: const Color(0xFFE8F4FF),
                iconColor: const Color(0xFF2196F3),
                title: 'Tema Aplikasi',
                subtitle: 'Pilih tema aplikasi',
                trailing: Text(_selectedTheme, style: const TextStyle(fontSize: 13, color: Color(0xFF8E8E93), fontFamily: 'Inter')),
                onTap: _pickTheme,
              ),
              const Divider(height: 1, color: Color(0xFFF0F1F5), indent: 16, endIndent: 16),
              _prefRow(
                icon: Icons.language_rounded,
                iconBg: const Color(0xFFE8F4FF),
                iconColor: const Color(0xFF2196F3),
                title: 'Bahasa',
                subtitle: 'Bahasa aplikasi',
                trailing: Text(_selectedLanguage, style: const TextStyle(fontSize: 13, color: Color(0xFF8E8E93), fontFamily: 'Inter')),
                onTap: _pickLanguage,
              ),
            ]),

            const SizedBox(height: 24),

            // ── Notifikasi ─────────────────────────────────────
            _sectionTitle('Notifikasi'),
            const SizedBox(height: 10),
            _card(children: [
              _toggleRow(
                icon: Icons.notifications_none_outlined,
                title: 'Notifikasi Push',
                subtitle: 'Terima notifikasi di perangkat',
                value: _pushNotif,
                onChanged: (v) => setState(() => _pushNotif = v),
                isFirst: true,
              ),
              const Divider(height: 1, color: Color(0xFFF0F1F5), indent: 16, endIndent: 16),
              _toggleRow(
                icon: Icons.email_outlined,
                title: 'Email Notifikasi',
                subtitle: 'Terima notifikasi melalui email',
                value: _emailNotif,
                onChanged: (v) => setState(() => _emailNotif = v),
              ),
              const Divider(height: 1, color: Color(0xFFF0F1F5), indent: 16, endIndent: 16),
              _toggleRow(
                icon: Icons.folder_outlined,
                title: 'Notifikasi Proyek',
                subtitle: 'Update terkait proyek terkait',
                value: _projectNotif,
                onChanged: (v) => setState(() => _projectNotif = v),
              ),
              const Divider(height: 1, color: Color(0xFFF0F1F5), indent: 16, endIndent: 16),
              _toggleRow(
                icon: Icons.description_outlined,
                title: 'Notifikasi Laporan',
                subtitle: 'Pengingat dan status laporan',
                value: _reportNotif,
                onChanged: (v) => setState(() => _reportNotif = v),
                isLast: true,
              ),
            ]),

            const SizedBox(height: 24),

            // ── Lainnya ────────────────────────────────────────
            _sectionTitle('Lainnya'),
            const SizedBox(height: 10),
            _card(children: [
              _actionRow(
                icon: Icons.calendar_today_outlined,
                title: 'Reminder Laporan Harian',
                subtitle: 'Aktif setiap hari pukul $_reminderTime',
                onTap: _pickReminderTime,
                isFirst: true,
              ),
              const Divider(height: 1, color: Color(0xFFF0F1F5), indent: 16, endIndent: 16),
              _actionRow(
                icon: Icons.cloud_upload_outlined,
                title: 'Backup Data',
                subtitle: 'Terakhir backup: $_lastBackup',
                onTap: _doBackup,
              ),
              const Divider(height: 1, color: Color(0xFFF0F1F5), indent: 16, endIndent: 16),
              _actionRow(
                icon: Icons.delete_outline_rounded,
                title: 'Bersihkan Cache',
                subtitle: 'Ukuran cache: ${_cacheSize.toStringAsFixed(1)} MB',
                onTap: _clearCache,
                isLast: true,
              ),
            ]),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Widget Helpers ─────────────────────────────────────────

  Widget _sectionTitle(String title) => Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E), fontFamily: 'Inter'),
      );

  Widget _card({required List<Widget> children}) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8E8E8)),
        ),
        child: Column(children: children),
      );

  Widget _prefRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
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
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 20, color: iconColor),
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
            trailing,
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 18, color: Color(0xFFB0B3BE)),
          ],
        ),
      ),
    );
  }

  Widget _toggleRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 22, color: const Color(0xFF8E8E93)),
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFF001AFF),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFD0D0D0),
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }

  Widget _actionRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: const Color(0xFF8E8E93)),
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
            const Icon(Icons.chevron_right, size: 18, color: Color(0xFFB0B3BE)),
          ],
        ),
      ),
    );
  }
}

// ── Bottom-sheet option picker ─────────────────────────────────
class _OptionSheet extends StatelessWidget {
  final String title;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;

  const _OptionSheet({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Inter', color: Color(0xFF1E1E1E))),
          const SizedBox(height: 12),
          ...options.map((opt) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(opt, style: const TextStyle(fontSize: 14, fontFamily: 'Inter')),
                trailing: selected == opt
                    ? const Icon(Icons.check_circle_rounded, color: Color(0xFF001AFF))
                    : const Icon(Icons.radio_button_unchecked, color: Color(0xFFD0D0D0)),
                onTap: () {
                  onSelect(opt);
                  Navigator.of(context).pop();
                },
              )),
        ],
      ),
    );
  }
}
