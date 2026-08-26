import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/enums/app_role.dart';
import '../../../widgets/laporan_menu_card.dart';
import '../../auth/presentation/auth_controller.dart';
import 'data_laporan_screen.dart';
import 'contractor_report_form.dart';
import 'supervisor_report_form.dart';
import 'pending_approvals_screen.dart';
import 'rekap_laporan_screen.dart';
import 'contractor_report_status_screen.dart';

class ReportScreen extends ConsumerWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final role = authState.valueOrNull?.role ?? AppRole.eksternal;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Menu 1: Data Laporan (Visible to all)
            LaporanMenuCard(
              iconColor: const Color(0xFF1565C0),
              iconBackgroundColor: const Color(0xFFE3EFFD),
              icon: Icons.folder_outlined,
              title: 'Data Laporan',
              subtitle: role == AppRole.kontraktor
                  ? 'Lihat daftar proyek Anda dan riwayat laporan terkirim'
                  : role == AppRole.eksternal
                      ? 'Lihat informasi laporan proyek Jembatan yang dibagikan'
                      : 'Lihat daftar proyek dan semua data laporan tersedia',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const DataLaporanScreen()),
              ),
            ),

            // Menu 2: Buat Laporan Pengawasan (Konsultan only) or Buat Laporan Harian (Kontraktor only)
            if (role == AppRole.konsultan)
              LaporanMenuCard(
                iconColor: const Color(0xFF2E7D32),
                iconBackgroundColor: const Color(0xFFE6F4EA),
                icon: Icons.rate_review_outlined,
                title: 'Buat Laporan Pengawasan',
                subtitle: 'Isi temuan lapangan, kondisi, instruksi, dan rekomendasi',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SupervisorReportForm()),
                ),
              ),

            if (role == AppRole.kontraktor)
              LaporanMenuCard(
                iconColor: const Color(0xFF2E7D32),
                iconBackgroundColor: const Color(0xFFE6F4EA),
                icon: Icons.note_add_outlined,
                title: 'Buat Laporan Harian',
                subtitle: 'Kirim laporan progress harian, material, cuaca, dan kendala',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ContractorReportForm()),
                ),
              ),

            if (role == AppRole.kontraktor)
              LaporanMenuCard(
                iconColor: const Color(0xFFFF9100),
                iconBackgroundColor: const Color(0xFFFFF4E5),
                icon: Icons.checklist_rtl_rounded,
                title: 'Status Laporan Anda',
                subtitle: 'Pantau riwayat laporan harian, status persetujuan, dan revisi',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ContractorReportStatusScreen()),
                ),
              ),



          ],
        ),
      ),
    );
  }
}
