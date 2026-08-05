import 'package:hive_flutter/hive_flutter.dart';
import 'hive_models.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class HiveDatabaseService {
  static bool _isInitialized = false;

  static Future<void> initDb() async {
    if (_isInitialized) return;
    await Hive.initFlutter();
    
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserHiveAdapter());
      Hive.registerAdapter(ProjectHiveAdapter());
      Hive.registerAdapter(ProjectMemberHiveAdapter());
      Hive.registerAdapter(ProjectProgressHiveAdapter());
      Hive.registerAdapter(DocumentVersionHiveAdapter());
      Hive.registerAdapter(DocumentHiveAdapter());
      Hive.registerAdapter(ReportHistoryHiveAdapter());
      Hive.registerAdapter(ContractorReportHiveAdapter());
      Hive.registerAdapter(SupervisorReportHiveAdapter());
      Hive.registerAdapter(TimelineHiveAdapter());
      Hive.registerAdapter(NotificationHiveAdapter());
      Hive.registerAdapter(PhotoDocumentationHiveAdapter());
      Hive.registerAdapter(ActivityHistoryHiveAdapter());
    }

    final userBox = await Hive.openBox<UserHive>('users');
    await Hive.openBox<ProjectHive>('projects');
    await Hive.openBox<ProjectMemberHive>('projectMembers');
    await Hive.openBox<ProjectProgressHive>('projectProgress');
    await Hive.openBox<DocumentHive>('documents');
    await Hive.openBox<ContractorReportHive>('contractorReports');
    await Hive.openBox<SupervisorReportHive>('supervisorReports');
    await Hive.openBox<TimelineHive>('timelines');
    await Hive.openBox<NotificationHive>('notifications');
    await Hive.openBox<PhotoDocumentationHive>('photoDocumentation');
    await Hive.openBox<ActivityHistoryHive>('activityHistory');

    final userCount = userBox.length;
    final hasKonsultan = userBox.values.any((u) => u.username == 'konsultan');
    final String correctHash = 'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad';
    
    bool needsSeeding = userCount == 0 || !hasKonsultan;
    if (hasKonsultan) {
      final kons = userBox.values.firstWhere((u) => u.username == 'konsultan');
      if (kons.password != correctHash && kons.password != '123456') {
        needsSeeding = true;
      }
    }
    
    if (needsSeeding) {
      await _seedData();
    }
    _isInitialized = true;
  }

  static Future<void> _seedData() async {
    await Hive.box<UserHive>('users').clear();
    await Hive.box<ProjectHive>('projects').clear();
    await Hive.box<ProjectMemberHive>('projectMembers').clear();
    await Hive.box<ProjectProgressHive>('projectProgress').clear();
    await Hive.box<DocumentHive>('documents').clear();
    await Hive.box<ContractorReportHive>('contractorReports').clear();
    await Hive.box<SupervisorReportHive>('supervisorReports').clear();
    await Hive.box<TimelineHive>('timelines').clear();
    await Hive.box<NotificationHive>('notifications').clear();
    await Hive.box<PhotoDocumentationHive>('photoDocumentation').clear();
    await Hive.box<ActivityHistoryHive>('activityHistory').clear();

String hashPwd(String p) {
          final bytes = utf8.encode(p);
          return sha256.convert(bytes).toString();
        }

        // Users
        final users = [
          UserHive()
            ..userId = 'user-1'
            ..name = 'Aradea Kingdom'
            ..username = 'konsultan'
            ..password = hashPwd('123456')
            ..role = 'konsultan'
            ..email = 'konsultan@tatasaka.com'
            ..phone = '081234567890'
            ..isActive = true,
          UserHive()
            ..userId = 'user-2'
            ..name = 'Budi Kontraktor'
            ..username = 'kontraktor'
            ..password = hashPwd('123456')
            ..role = 'kontraktor'
            ..email = 'budi@kontraktor.com'
            ..phone = '081234567891'
            ..isActive = true,
          UserHive()
            ..userId = 'user-3'
            ..name = 'Dinas PUPR'
            ..username = 'dinas'
            ..password = hashPwd('123456')
            ..role = 'dinas'
            ..email = 'dinas@pupr.com'
            ..phone = '081234567892'
            ..isActive = true,
          UserHive()
            ..userId = 'user-4'
            ..name = 'Rina Eksternal'
            ..username = 'eksternal'
            ..password = hashPwd('123456')
            ..role = 'eksternal'
            ..email = 'rina@external.com'
            ..phone = '081234567893'
            ..isActive = true,
          UserHive()
            ..userId = 'user-5'
            ..name = 'Koko Kontraktor'
            ..username = 'kontraktor2'
            ..password = hashPwd('123456')
            ..role = 'kontraktor'
            ..email = 'koko@kontraktor.com'
            ..phone = '081234567894'
            ..isActive = true,
        ];
        for (var i in users) { Hive.box<UserHive>('users').put(i.userId, i); }

        // Projects
        final projects = [
          ProjectHive()
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
          ProjectHive()
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
          ProjectHive()
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
        for (var i in projects) { Hive.box<ProjectHive>('projects').put(i.projectId, i); }

        // Project Members
        // project-1: Budi Kontraktor (Pelaksana), Aradea/Konsultan (Pengawas), Dinas PUPR (Pengawas Dinas)
        // project-2: Budi Kontraktor (Pelaksana), Aradea/Konsultan (Pengawas)
        // project-3: Koko Kontraktor (Pelaksana), Konsultan (Pengawas), Dinas PUPR (Pengawas Dinas)
        final members = [
          ProjectMemberHive()
            ..projectId = 'project-1'
            ..userId = 'user-1'   // Aradea - Konsultan
            ..role = 'Pengawas',
          ProjectMemberHive()
            ..projectId = 'project-1'
            ..userId = 'user-2'   // Budi - Kontraktor
            ..role = 'Pelaksana',
          ProjectMemberHive()
            ..projectId = 'project-1'
            ..userId = 'user-3'   // Dinas PUPR
            ..role = 'Pengawas Dinas',
          ProjectMemberHive()
            ..projectId = 'project-2'
            ..userId = 'user-1'   // Aradea - Konsultan
            ..role = 'Pengawas',
          ProjectMemberHive()
            ..projectId = 'project-2'
            ..userId = 'user-2'   // Budi - Kontraktor
            ..role = 'Pelaksana',
          ProjectMemberHive()
            ..projectId = 'project-3'
            ..userId = 'user-1'   // Aradea - Konsultan
            ..role = 'Pengawas',
          ProjectMemberHive()
            ..projectId = 'project-3'
            ..userId = 'user-5'   // Koko - Kontraktor
            ..role = 'Pelaksana',
          ProjectMemberHive()
            ..projectId = 'project-3'
            ..userId = 'user-3'   // Dinas PUPR
            ..role = 'Pengawas Dinas',
        ];
        for (var i in members) { Hive.box<ProjectMemberHive>('projectMembers').add(i); }

        // Documents
        final documents = [
          DocumentHive()
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
              DocumentVersionHive()
                ..versionId = 'ver-1-1-1'
                ..name = 'LoremIpsum_draft.pdf'
                ..fileUrl = '/documents/lorem_ipsum_draft.pdf'
                ..fileSize = '1.1 MB'
                ..uploadedBy = 'Aradea Kingdom'
                ..uploadedAt = '2026-01-02 11:00'
                ..version = 1
            ],
          DocumentHive()
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
          DocumentHive()
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
          DocumentHive()
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
          DocumentHive()
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
          DocumentHive()
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
        for (var i in documents) { Hive.box<DocumentHive>('documents').put(i.documentId, i); }

        // Dynamic relative dates for reports seeder
        final today = DateTime.now();
        final todayStr = today.toString().substring(0, 10);
        final yesterdayStr = today.subtract(const Duration(days: 1)).toString().substring(0, 10);
        final twoDaysAgoStr = today.subtract(const Duration(days: 2)).toString().substring(0, 10);
        final threeDaysAgoStr = today.subtract(const Duration(days: 3)).toString().substring(0, 10);

        // Contractor Reports
        final contractorReports = [
          ContractorReportHive()
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
              ReportHistoryHive()
                ..date = '$twoDaysAgoStr 09:15'
                ..user = 'Budi Kontraktor'
                ..action = 'Dibuat'
                ..details = 'Laporan dikirim pertama kali.',
              ReportHistoryHive()
                ..date = '$twoDaysAgoStr 17:00'
                ..user = 'Aradea Kingdom'
                ..action = 'DISETUJUI'
                ..details = 'Laporan disetujui tanpa revisi.'
            ],
          ContractorReportHive()
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
              ReportHistoryHive()
                ..date = '$todayStr 16:30'
                ..user = 'Budi Kontraktor'
                ..action = 'Dibuat'
                ..details = 'Menunggu peninjauan pengawas.'
            ],
          ContractorReportHive()
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
              ReportHistoryHive()
                ..date = '$yesterdayStr 14:45'
                ..user = 'Budi Kontraktor'
                ..action = 'Dibuat'
                ..details = 'Laporan terkirim.',
              ReportHistoryHive()
                ..date = '$yesterdayStr 16:00'
                ..user = 'Dinas PUPR'
                ..action = 'DITOLAK'
                ..details = 'Ditolak karena sirtu tidak sesuai standar.'
            ],
        ];
        for (var i in contractorReports) { Hive.box<ContractorReportHive>('contractorReports').put(i.reportId, i); }

        // Supervisor Reports
        final supervisorReports = [
          SupervisorReportHive()
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
          SupervisorReportHive()
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
        for (var i in supervisorReports) { Hive.box<SupervisorReportHive>('supervisorReports').put(i.reportId, i); }

        // Timelines
        final timelines = [
          TimelineHive()
            ..timelineId = 'timeline-1'
            ..projectId = 'project-1'
            ..title = 'Project dibuat'
            ..description = 'Proyek Pembangunan Jembatan berhasil dibuat.'
            ..user = 'Aradea Kingdom'
            ..role = 'Konsultan'
            ..icon = 'timeline'
            ..createdAt = '2026-06-28 10:00',
          TimelineHive()
            ..timelineId = 'timeline-2'
            ..projectId = 'project-1'
            ..title = 'Folder Pra Kontrak Dibuat'
            ..description = 'Folder administrasi Pra Kontrak ditambahkan.'
            ..user = 'Aradea Kingdom'
            ..role = 'Konsultan'
            ..icon = 'folder'
            ..createdAt = '2026-06-28 11:30',
          TimelineHive()
            ..timelineId = 'timeline-3'
            ..projectId = 'project-1'
            ..title = 'Laporan dikirim'
            ..description = 'Laporan harian kontraktor STA 13 dikirim untuk verifikasi.'
            ..user = 'Budi Kontraktor'
            ..role = 'Kontraktor'
            ..icon = 'report'
            ..createdAt = '2026-06-29 08:00',
        ];
        for (var i in timelines) { Hive.box<TimelineHive>('timelines').put(i.timelineId, i); }

        // Notifications
        final notifications = [
          NotificationHive()
            ..notificationId = 'notif-1'
            ..title = 'Approval'
            ..message = 'Laporan harian proyek Jembatan STA 13 menunggu verifikasi.'
            ..type = 'Approval'
            ..isRead = false
            ..createdAt = '2026-06-29 09:00',
          NotificationHive()
            ..notificationId = 'notif-2'
            ..title = 'Revisi'
            ..message = 'Laporan aspal jalan desa ditolak oleh pengawas. Perlu revisi sirtu.'
            ..type = 'Revisi'
            ..isRead = false
            ..createdAt = '2026-06-29 08:30',
          NotificationHive()
            ..notificationId = 'notif-3'
            ..title = 'Dokumen Baru'
            ..message = 'Dokumen Adendum_Final.pdf telah diunggah oleh CV. Tata Saka Consultant.'
            ..type = 'Dokumen Baru'
            ..isRead = true
            ..createdAt = '2026-06-28 14:00',
        ];
        for (var i in notifications) { Hive.box<NotificationHive>('notifications').put(i.notificationId, i); }
      
  }
}
