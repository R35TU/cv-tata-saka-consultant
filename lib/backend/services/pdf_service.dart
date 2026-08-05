// =============================================================
// FILE   : lib/backend/services/pdf_service.dart
// TEKNIK : Code Reuse / Library
// -------------------------------------------------------------
// FUNGSI :
//   Menghasilkan file PDF laporan proyek menggunakan package 'pdf'
//   dan menampilkan/download-nya via package 'printing'.
//   Dipanggil dari berbagai screen — itulah mengapa masuk Code Reuse.
//
// METHOD YANG PERLU DIBUAT :
//   - generateReportPdf(ReportModel)      : buat PDF satu laporan
//   - generateProjectSummaryPdf(ProjectModel) : buat PDF rekap proyek
//   - printOrDownload(Uint8List pdfBytes) : tampilkan dialog print/download
//
// CARA PAKAI :
//   import 'package:pdf/pdf.dart';
//   import 'package:pdf/widgets.dart' as pw;
//   import 'package:printing/printing.dart';
//
// CATATAN CODE REUSE :
//   Service ini dipanggil ulang dari report_detail, dashboard,
//   dan admin page — tidak ada duplikasi kode PDF di mana pun.
// =============================================================
