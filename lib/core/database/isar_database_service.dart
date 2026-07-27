import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'isar_models.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class IsarDatabaseService {
  static Isar? _instance;

  static Future<Isar> get db async {
    if (_instance != null) return _instance!;
    _instance = await _initDb();
    return _instance!;
  }

  static Future<Isar> _initDb() async {
    final existing = Isar.getInstance();
    final isar = existing ?? await Isar.open(
      [
        UserIsarSchema,
        ProjectIsarSchema,
        ProjectMemberIsarSchema,
        ProjectProgressIsarSchema,
        DocumentIsarSchema,
        ContractorReportIsarSchema,
        SupervisorReportIsarSchema,
        TimelineIsarSchema,
        NotificationIsarSchema,
        PhotoDocumentationIsarSchema,
        ActivityHistoryIsarSchema,
      ],
      directory: (await getApplicationDocumentsDirectory()).path,
    );

    // Seed if empty, if 'konsultan' user is missing, or if its password is out of sync
    final userCount = await isar.userIsars.count();
    final hasKonsultan = await isar.userIsars.filter().usernameEqualTo('konsultan').findFirst();
    final String correctHash = 'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad';
    
    bool needsSeeding = userCount == 0 || hasKonsultan == null;
    if (hasKonsultan != null && hasKonsultan.password != correctHash && hasKonsultan.password != '123456') {
      needsSeeding = true;
    }
    
    if (needsSeeding) {
      await isar.writeTxn(() async {
        await isar.userIsars.clear();
        await isar.projectIsars.clear();
        await isar.projectMemberIsars.clear();
        await isar.projectProgressIsars.clear();
        await isar.documentIsars.clear();
        await isar.contractorReportIsars.clear();
        await isar.supervisorReportIsars.clear();
        await isar.timelineIsars.clear();
        await isar.notificationIsars.clear();
        await isar.photoDocumentationIsars.clear();
        await isar.activityHistoryIsars.clear();
      });

      await isar.writeTxn(() async {
        String hashPwd(String p) {
          final bytes = utf8.encode(p);
          return sha256.convert(bytes).toString();
        }

        // Users
        final users = [
          UserIsar()
            ..userId = 'user-1'
            ..name = 'Aradea Kingdom'
            ..username = 'konsultan'
            ..password = hashPwd('123456')
            ..role = 'konsultan'
            ..email = 'konsultan@tatasaka.com'
            ..phone = '081234567890'
            ..isActive = true,
          UserIsar()
            ..userId = 'user-2'
            ..name = 'Budi Kontraktor'
            ..username = 'kontraktor'
            ..password = hashPwd('123456')
            ..role = 'kontraktor'
            ..email = 'budi@kontraktor.com'
            ..phone = '081234567891'
            ..isActive = true,
          UserIsar()
            ..userId = 'user-3'
            ..name = 'Dinas PUPR'
            ..username = 'dinas'
            ..password = hashPwd('123456')
            ..role = 'dinas'
            ..email = 'dinas@pupr.com'
            ..phone = '081234567892'
            ..isActive = true,
          UserIsar()
            ..userId = 'user-4'
            ..name = 'Rina Eksternal'
            ..username = 'eksternal'
            ..password = hashPwd('123456')
            ..role = 'eksternal'
            ..email = 'rina@external.com'
            ..phone = '081234567893'
            ..isActive = true,
          UserIsar()
            ..userId = 'user-5'
            ..name = 'Koko Kontraktor'
            ..username = 'kontraktor2'
            ..password = hashPwd('123456')
            ..role = 'kontraktor'
            ..email = 'koko@kontraktor.com'
            ..phone = '081234567894'
            ..isActive = true,
        ];
        await isar.userIsars.putAll(users);

        // Projects
        final projects = [
          ProjectIsar()
            ..projectId = 'project-1'
            ..name = 'Pembangunan Jembatan'
            ..location = 'Purwokerto'
            ..status = 'Progres'
            ..physicalProgress = 0.82
            ..financialProgress = 0.50
            ..imageUrl = 'https://images.unsplash.com/photo-1545628221-bb35ab299e58?q=80&w=600&auto=format&fit=crop'
            ..description = 'Pembangunan jembatan penghubung utama kawasan industri.'
            ..owner = 'Budi Kontraktor'
            ..supervisor = 'Aradea Kingdom'
            ..createdAt = '2025-01-10'
            ..startDate = '1 Januari 2026'
            ..endDate = '30 Juni 2026'
            ..ownerDetail = 'Pemerintah Kabupaten Banyumas'
            ..fundingSource = 'APBD 2026'
            ..isArchived = false,
          ProjectIsar()
            ..projectId = 'project-2'
            ..name = 'Gor Hebat Mantap'
            ..location = 'Purbalingga'
            ..status = 'Selesai'
            ..physicalProgress = 1.00
            ..financialProgress = 1.00
            ..imageUrl = 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?q=80&w=600&auto=format&fit=crop'
            ..description = 'Pembangunan gedung olahraga dan fasilitas penunjang.'
            ..owner = 'Budi Kontraktor'
            ..supervisor = 'Aradea Kingdom'
            ..createdAt = '2024-09-02'
            ..startDate = '1 September 2024'
            ..endDate = '31 Desember 2024'
            ..ownerDetail = 'Pemerintah Kabupaten Purbalingga'
            ..fundingSource = 'APBD 2024'
            ..isArchived = false,
          ProjectIsar()
            ..projectId = 'project-3'
            ..name = 'Pengecoran Jalan Desa'
            ..location = 'Kebumen'
            ..status = 'Progres'
            ..physicalProgress = 0.14
            ..financialProgress = 0.20
            ..imageUrl = 'https://images.unsplash.com/photo-1579684385127-1ef15d508118?q=80&w=600&auto=format&fit=crop'
            ..description = 'Pekerjaan perkerasan dan drainase jalan desa.'
            ..owner = 'Budi Kontraktor'
            ..supervisor = 'Dinas PUPR'
            ..createdAt = '2025-03-20'
            ..startDate = '15 Maret 2025'
            ..endDate = '15 Agustus 2025'
            ..ownerDetail = 'Pemerintah Kabupaten Kebumen'
            ..fundingSource = 'APBD 2025'
            ..isArchived = false,
        ];
        await isar.projectIsars.putAll(projects);

        // Project Members
        // project-1: Budi Kontraktor (Pelaksana), Aradea/Konsultan (Pengawas), Dinas PUPR (Pengawas Dinas)
        // project-2: Budi Kontraktor (Pelaksana), Aradea/Konsultan (Pengawas)
        // project-3: Koko Kontraktor (Pelaksana), Konsultan (Pengawas), Dinas PUPR (Pengawas Dinas)
        final members = [
          ProjectMemberIsar()
            ..projectId = 'project-1'
            ..userId = 'user-1'   // Aradea - Konsultan
            ..role = 'Pengawas',
          ProjectMemberIsar()
            ..projectId = 'project-1'
            ..userId = 'user-2'   // Budi - Kontraktor
            ..role = 'Pelaksana',
          ProjectMemberIsar()
            ..projectId = 'project-1'
            ..userId = 'user-3'   // Dinas PUPR
            ..role = 'Pengawas Dinas',
          ProjectMemberIsar()
            ..projectId = 'project-2'
            ..userId = 'user-1'   // Aradea - Konsultan
            ..role = 'Pengawas',
          ProjectMemberIsar()
            ..projectId = 'project-2'
            ..userId = 'user-2'   // Budi - Kontraktor
            ..role = 'Pelaksana',
          ProjectMemberIsar()
            ..projectId = 'project-3'
            ..userId = 'user-1'   // Aradea - Konsultan
            ..role = 'Pengawas',
          ProjectMemberIsar()
            ..projectId = 'project-3'
            ..userId = 'user-5'   // Koko - Kontraktor
            ..role = 'Pelaksana',
          ProjectMemberIsar()
            ..projectId = 'project-3'
            ..userId = 'user-3'   // Dinas PUPR
            ..role = 'Pengawas Dinas',
        ];
        await isar.projectMemberIsars.putAll(members);

        // Documents
        final documents = [
          DocumentIsar()
            ..documentId = 'doc-1-1'
            ..projectId = 'project-1'
            ..folderName = 'Dokumen Pra Kontrak'
            ..name = 'LoremIpsum.pdf'
            ..fileUrl = '/documents/lorem_ipsum.pdf'
            ..fileSize = '1.2 MB'
            ..uploadedBy = 'Aradea Kingdom'
            ..uploadedAt = '2026-01-02 11:30'
            ..version = 1
            ..versions = [
              DocumentVersionIsar()
                ..versionId = 'ver-1-1-1'
                ..name = 'LoremIpsum_draft.pdf'
                ..fileUrl = '/documents/lorem_ipsum_draft.pdf'
                ..fileSize = '1.1 MB'
                ..uploadedBy = 'Aradea Kingdom'
                ..uploadedAt = '2026-01-02 11:00'
                ..version = 1
            ],
          DocumentIsar()
            ..documentId = 'doc-1-2'
            ..projectId = 'project-1'
            ..folderName = 'Dokumen Pra Kontrak'
            ..name = 'HebatKamuTuh.txt'
            ..fileUrl = '/documents/hebat.txt'
            ..fileSize = '4 KB'
            ..uploadedBy = 'Aradea Kingdom'
            ..uploadedAt = '2026-01-02 11:32'
            ..version = 1
            ..versions = [],
          DocumentIsar()
            ..documentId = 'doc-1-4'
            ..projectId = 'project-1'
            ..folderName = 'Dokumen Kontrak'
            ..name = 'SuratPerjanjian.pdf'
            ..fileUrl = '/documents/surat_perjanjian.pdf'
            ..fileSize = '3.4 MB'
            ..uploadedBy = 'Aradea Kingdom'
            ..uploadedAt = '2026-01-04 11:30'
            ..version = 1
            ..versions = [],
          DocumentIsar()
            ..documentId = 'doc-1-6'
            ..projectId = 'project-1'
            ..folderName = 'PCM'
            ..name = 'NotulenPCM.pdf'
            ..fileUrl = '/documents/notulen_pcm.pdf'
            ..fileSize = '450 KB'
            ..uploadedBy = 'Aradea Kingdom'
            ..uploadedAt = '2026-01-05 11:35'
            ..version = 1
            ..versions = [],
          DocumentIsar()
            ..documentId = 'doc-1-7'
            ..projectId = 'project-1'
            ..folderName = 'Adendum'
            ..name = 'Adendum_Final.pdf'
            ..fileUrl = '/documents/adendum_final.pdf'
            ..fileSize = '1.8 MB'
            ..uploadedBy = 'Aradea Kingdom'
            ..uploadedAt = '2026-01-05 11:40'
            ..version = 1
            ..versions = [],
          DocumentIsar()
            ..documentId = 'doc-3-1'
            ..projectId = 'project-3'
            ..folderName = 'Dokumen Kontrak'
            ..name = 'Kontrak_Jalan_Desa.pdf'
            ..fileUrl = '/documents/kontrak_jalan.pdf'
            ..fileSize = '2.8 MB'
            ..uploadedBy = 'Dinas PUPR'
            ..uploadedAt = '2026-03-20 09:15'
            ..version = 1
            ..versions = [],
        ];
        await isar.documentIsars.putAll(documents);

        // Dynamic relative dates for reports seeder
        final today = DateTime.now();
        final todayStr = today.toString().substring(0, 10);
        final yesterdayStr = today.subtract(const Duration(days: 1)).toString().substring(0, 10);
        final twoDaysAgoStr = today.subtract(const Duration(days: 2)).toString().substring(0, 10);
        final threeDaysAgoStr = today.subtract(const Duration(days: 3)).toString().substring(0, 10);

        // Contractor Reports
        final contractorReports = [
          ContractorReportIsar()
            ..reportId = 'rep-c-1'
            ..projectId = 'project-1'
            ..date = twoDaysAgoStr
            ..time = '09:15'
            ..weather = 'Cerah'
            ..location = 'Purwokerto STA 12'
            ..todayProgress = 0.05
            ..tasksDone = 'Pengecoran tiang pancang A1 dan A2.'
            ..materialsUsed = 'Semen 150 sak, Pasir 10 rit, Besi ulir 12mm.'
            ..toolsUsed = 'Concrete mixer 2 unit, Excavator 1 unit.'
            ..workersCount = '15 Pekerja, 1 Mandor, 1 Safety Officer'
            ..obstacles = 'Tidak ada.'
            ..solutions = 'Tidak ada.'
            ..notes = 'Pekerjaan selesai tepat waktu.'
            ..photos = ['https://images.unsplash.com/photo-1545628221-bb35ab299e58?q=80&w=300&auto=format&fit=crop']
            ..attachments = ['attachment_pancang.pdf']
            ..status = 'DISETUJUI'
            ..reviewerName = 'Aradea Kingdom'
            ..verificationDate = '$twoDaysAgoStr 17:00'
            ..revisionNotes = ''
            ..changeHistory = [
              ReportHistoryIsar()
                ..date = '$twoDaysAgoStr 09:15'
                ..user = 'Budi Kontraktor'
                ..action = 'Dibuat'
                ..details = 'Laporan dikirim pertama kali.',
              ReportHistoryIsar()
                ..date = '$twoDaysAgoStr 17:00'
                ..user = 'Aradea Kingdom'
                ..action = 'DISETUJUI'
                ..details = 'Laporan disetujui tanpa revisi.'
            ],
          ContractorReportIsar()
            ..reportId = 'rep-c-2'
            ..projectId = 'project-1'
            ..date = todayStr
            ..time = '16:30'
            ..weather = 'Hujan Gerimis'
            ..location = 'Purwokerto STA 13'
            ..todayProgress = 0.03
            ..tasksDone = 'Pemasangan bekisting dan pembesian gelagar utama.'
            ..materialsUsed = 'Kayu bekisting 40 lembar, Kawat bendrat.'
            ..toolsUsed = 'Bar cutter 1 unit, Bar bender 1 unit.'
            ..workersCount = '12 Pekerja, 1 Mandor'
            ..obstacles = 'Hujan di sore hari menghambat pekerjaan las.'
            ..solutions = 'Menyiapkan tenda pelindung area las.'
            ..notes = 'Kecepatan pengerjaan berkurang karena faktor cuaca.'
            ..photos = ['https://images.unsplash.com/photo-1504307651254-35680f356dfd?q=80&w=300&auto=format&fit=crop']
            ..attachments = ['attachment_pembesian.pdf']
            ..status = 'MENUNGGU VERIFIKASI'
            ..reviewerName = ''
            ..verificationDate = ''
            ..revisionNotes = ''
            ..changeHistory = [
              ReportHistoryIsar()
                ..date = '$todayStr 16:30'
                ..user = 'Budi Kontraktor'
                ..action = 'Dibuat'
                ..details = 'Menunggu peninjauan pengawas.'
            ],
          ContractorReportIsar()
            ..reportId = 'rep-c-3'
            ..projectId = 'project-3'
            ..date = yesterdayStr
            ..time = '14:45'
            ..weather = 'Cerah'
            ..location = 'Kebumen STA 02'
            ..todayProgress = 0.04
            ..tasksDone = 'Leveling badan jalan.'
            ..materialsUsed = 'Sirtu 5 rit.'
            ..toolsUsed = 'Vibratory roller 1 unit.'
            ..workersCount = '8 Pekerja'
            ..obstacles = 'Salah jenis pasir.'
            ..solutions = 'Meminta pengiriman ulang pasir beton.'
            ..notes = 'Perlu revisi material beton.'
            ..photos = []
            ..attachments = []
            ..status = 'DITOLAK'
            ..reviewerName = 'Dinas PUPR'
            ..verificationDate = '$yesterdayStr 16:00'
            ..revisionNotes = 'Spesifikasi material sirtu tidak sesuai standar kontrak, ganti material kelas A!'
            ..changeHistory = [
              ReportHistoryIsar()
                ..date = '$yesterdayStr 14:45'
                ..user = 'Budi Kontraktor'
                ..action = 'Dibuat'
                ..details = 'Laporan terkirim.',
              ReportHistoryIsar()
                ..date = '$yesterdayStr 16:00'
                ..user = 'Dinas PUPR'
                ..action = 'DITOLAK'
                ..details = 'Ditolak karena sirtu tidak sesuai standar.'
            ],
        ];
        await isar.contractorReportIsars.putAll(contractorReports);

        // Supervisor Reports
        final supervisorReports = [
          SupervisorReportIsar()
            ..reportId = 'rep-s-1'
            ..projectId = 'project-1'
            ..date = threeDaysAgoStr
            ..time = '08:30'
            ..supervisorName = 'Aradea Kingdom'
            ..location = 'Purwokerto Jembatan'
            ..weather = 'Cerah'
            ..findings = 'Pekerjaan galian pondasi dimulai.'
            ..fieldConditions = 'Kondisi tanah stabil, cuaca cerah mendukung.'
            ..instructions = 'Pastikan kedalaman galian sesuai gambar shop drawing (STA 12).'
            ..recommendations = 'Gunakan penopang galian jika kedalaman melebihi 2 meter.'
            ..notes = 'Selalu gunakan helm dan rompi K3 di area galian.'
            ..photos = ['https://images.unsplash.com/photo-1545628221-bb35ab299e58?q=80&w=300&auto=format&fit=crop']
            ..attachments = ['instruksi_galian.pdf'],
          SupervisorReportIsar()
            ..reportId = 'rep-s-2'
            ..projectId = 'project-1'
            ..date = yesterdayStr
            ..time = '08:00'
            ..supervisorName = 'Aradea Kingdom'
            ..location = 'Purwokerto STA 12'
            ..weather = 'Berawan'
            ..findings = 'Pembesian tiang pancang selesai dirakit.'
            ..fieldConditions = 'Besi bersih dari karat, pengerjaan rapi.'
            ..instructions = 'Cek ulang jarak sengkang pembesian tiang pancang sebelum dicor.'
            ..recommendations = 'Segera lakukan pengecoran sebelum hujan.'
            ..notes = 'Dokumentasikan proses penulangan.'
            ..photos = []
            ..attachments = [],
        ];
        await isar.supervisorReportIsars.putAll(supervisorReports);

        // Timelines
        final timelines = [
          TimelineIsar()
            ..timelineId = 'timeline-1'
            ..projectId = 'project-1'
            ..title = 'Project dibuat'
            ..description = 'Proyek Pembangunan Jembatan berhasil dibuat.'
            ..user = 'Aradea Kingdom'
            ..role = 'Konsultan'
            ..icon = 'timeline'
            ..createdAt = '2026-06-28 10:00',
          TimelineIsar()
            ..timelineId = 'timeline-2'
            ..projectId = 'project-1'
            ..title = 'Folder Pra Kontrak Dibuat'
            ..description = 'Folder administrasi Pra Kontrak ditambahkan.'
            ..user = 'Aradea Kingdom'
            ..role = 'Konsultan'
            ..icon = 'folder'
            ..createdAt = '2026-06-28 11:30',
          TimelineIsar()
            ..timelineId = 'timeline-3'
            ..projectId = 'project-1'
            ..title = 'Laporan dikirim'
            ..description = 'Laporan harian kontraktor STA 13 dikirim untuk verifikasi.'
            ..user = 'Budi Kontraktor'
            ..role = 'Kontraktor'
            ..icon = 'report'
            ..createdAt = '2026-06-29 08:00',
        ];
        await isar.timelineIsars.putAll(timelines);

        // Notifications
        final notifications = [
          NotificationIsar()
            ..notificationId = 'notif-1'
            ..title = 'Approval'
            ..message = 'Laporan harian proyek Jembatan STA 13 menunggu verifikasi.'
            ..type = 'Approval'
            ..isRead = false
            ..createdAt = '2026-06-29 09:00',
          NotificationIsar()
            ..notificationId = 'notif-2'
            ..title = 'Revisi'
            ..message = 'Laporan aspal jalan desa ditolak oleh pengawas. Perlu revisi sirtu.'
            ..type = 'Revisi'
            ..isRead = false
            ..createdAt = '2026-06-29 08:30',
          NotificationIsar()
            ..notificationId = 'notif-3'
            ..title = 'Dokumen Baru'
            ..message = 'Dokumen Adendum_Final.pdf telah diunggah oleh CV. Tata Saka Consultant.'
            ..type = 'Dokumen Baru'
            ..isRead = true
            ..createdAt = '2026-06-28 14:00',
        ];
        await isar.notificationIsars.putAll(notifications);
      });
    }
    return isar;
  }
}
