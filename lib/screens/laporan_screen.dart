import 'package:flutter/material.dart';
import '../widgets/laporan_menu_card.dart';
import 'data_laporan_screen.dart';

/// Laporan Proyek screen showing four report-type menu items.
class LaporanScreen extends StatelessWidget {
  const LaporanScreen({super.key});

  void _onMenuTap(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title diklik'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Data Laporan
            LaporanMenuCard(
              iconColor: const Color(0xFF1565C0),
              iconBackgroundColor: const Color(0xFFE3EFFD),
              icon: Icons.folder_outlined,
              title: 'Data Laporan',
              subtitle: 'Lihat daftar proyek dan semua data laporan yang tersedia',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const DataLaporanScreen(),
                ),
              ),
            ),

            // 2. Buat Laporan Pengawasan
            LaporanMenuCard(
              iconColor: const Color(0xFF2E7D32),
              iconBackgroundColor: const Color(0xFFE6F4EA),
              icon: Icons.edit_document,
              title: 'Buat Laporan Pengawasan',
              subtitle: 'Buat Laporan Pengawasan Harian Proyek',
              onTap: () => _onMenuTap(context, 'Buat Laporan Pengawasan'),
            ),

            // 3. Permintaan Konfirmasi Laporan
            LaporanMenuCard(
              iconColor: const Color(0xFFE65100),
              iconBackgroundColor: const Color(0xFFFFF0E0),
              icon: Icons.file_present_rounded,
              title: 'Permintaan Konfirmasi Laporan',
              subtitle: 'Laporan Kontraktor untuk dikonfirmasi',
              onTap: () => _onMenuTap(context, 'Permintaan Konfirmasi Laporan'),
            ),

            // 4. Rekap Laporan
            LaporanMenuCard(
              iconColor: const Color(0xFF6A1B9A),
              iconBackgroundColor: const Color(0xFFF3E5F5),
              icon: Icons.upload_file_rounded,
              title: 'Rekap Laporan',
              subtitle: 'Generate Rekap Laporan Mingguan / Bulanan',
              onTap: () => _onMenuTap(context, 'Rekap Laporan'),
            ),
          ],
        ),
      ),
    );
  }
}
