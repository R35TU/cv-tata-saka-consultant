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
        ContractIsarSchema,
        ProjectIsarSchema,
        ContractMemberIsarSchema,
        ContractProgressIsarSchema,
        DocumentIsarSchema,
        ContractorReportIsarSchema,
        SupervisorReportIsarSchema,
        TimelineIsarSchema,
        NotificationIsarSchema,
        PhotoDocumentationIsarSchema,
        ContractHistoryIsarSchema,
        FolderIsarSchema,
      ],
      directory: (await getApplicationDocumentsDirectory()).path,
    );

    // ── DB Version Check ──────────────────────────────────────────────────────
    // Bump kExpectedDbVersion whenever seed data changes to force a full reset.
    const String kExpectedDbVersion = 'v8';
    final versionRecord = await isar.userIsars
        .filter().userIdEqualTo('__db_version__').findFirst();
    final bool needsSeeding = (versionRecord?.name ?? '') != kExpectedDbVersion;

    if (needsSeeding) {
      // ── Step 1: Clear everything ─────────────────────────────────────────
      await isar.writeTxn(() async {
        await isar.userIsars.clear();
        await isar.contractIsars.clear();
        await isar.projectIsars.clear();
        await isar.contractMemberIsars.clear();
        await isar.contractProgressIsars.clear();
        await isar.documentIsars.clear();
        await isar.contractorReportIsars.clear();
        await isar.supervisorReportIsars.clear();
        await isar.timelineIsars.clear();
        await isar.notificationIsars.clear();
        await isar.photoDocumentationIsars.clear();
        await isar.contractHistoryIsars.clear();
      });

      // ── Step 2: Seed base data (users, projects, docs, reports) ─────────
      await isar.writeTxn(() async {
        String hashPwd(String p) {
          final bytes = utf8.encode(p);
          return sha256.convert(bytes).toString();
        }

        // ── Users ──
        await isar.userIsars.putAll([
          UserIsar()
            ..userId = 'user-1'
            ..name = 'CV. Tata Saka Konsultan'
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
          // DB version sentinel
          UserIsar()
            ..userId = '__db_version__'
            ..name = kExpectedDbVersion
            ..username = '__version__'
            ..password = ''
            ..role = '__version__'
            ..email = ''
            ..phone = ''
            ..isActive = false,
        ]);

        // Removed Project, Document, Report, Timeline, and Notification dummy data as per Day 1 refactor
      }); // end writeTxn seeding
    } // end needsSeeding

    // ── Step 3: ALWAYS sync ProjectMemberIsar from current user data ─────────
    // Runs every startup to keep Tim Proyek consistent:
    //   A. Kontraktor (owner field)   → 'Pelaksana'     (this project only)
    //   B. Konsultan  (supervisor field, must be konsultan role) → 'Pengawas'
    //   C. ALL konsultan users        → 'Pengawas'      (every project)
    //   D. ALL dinas users            → 'Pengawas Dinas' (every project)
    await isar.writeTxn(() => isar.contractMemberIsars.clear());

    final allContracts = await isar.contractIsars.where().findAll();
    final allUsers    = await isar.userIsars
        .filter().not().userIdEqualTo('__db_version__').findAll();

    final konsultanUsers = allUsers.where((u) => u.role == 'konsultan').toList();
    final dinasUsers     = allUsers.where((u) => u.role == 'dinas').toList();

    for (final act in allContracts) {
      final Set<String> addedUserIds = {};

      // A. Kontraktor Pelaksana (from owner name field)
      final ownerUser = allUsers.where((u) => u.name == act.owner).firstOrNull;
      if (ownerUser != null && !addedUserIds.contains(ownerUser.userId)) {
        await isar.writeTxn(() async {
          await isar.contractMemberIsars.put(
            ContractMemberIsar()
              ..contractId = act.contractId
              ..userId    = ownerUser.userId
              ..role      = 'Pelaksana',
          );
        });
        addedUserIds.add(ownerUser.userId);
      }

      // B. Designated supervisor (must be role=konsultan)
      final supervisorUser = allUsers.where(
        (u) => u.name == act.supervisor && u.role == 'konsultan',
      ).firstOrNull;
      if (supervisorUser != null && !addedUserIds.contains(supervisorUser.userId)) {
        await isar.writeTxn(() async {
          await isar.contractMemberIsars.put(
            ContractMemberIsar()
              ..contractId = act.contractId
              ..userId    = supervisorUser.userId
              ..role      = 'Pengawas',
          );
        });
        addedUserIds.add(supervisorUser.userId);
      }

      // C. All konsultan → Pengawas (every project)
      for (final ku in konsultanUsers) {
        if (!addedUserIds.contains(ku.userId)) {
          await isar.writeTxn(() async {
            await isar.contractMemberIsars.put(
              ContractMemberIsar()
                ..contractId = act.contractId
                ..userId    = ku.userId
                ..role      = 'Pengawas',
            );
          });
          addedUserIds.add(ku.userId);
        }
      }

      // D. All dinas → Pengawas Dinas (every project)
      for (final du in dinasUsers) {
        if (!addedUserIds.contains(du.userId)) {
          await isar.writeTxn(() async {
            await isar.contractMemberIsars.put(
              ContractMemberIsar()
                ..contractId = act.contractId
                ..userId    = du.userId
                ..role      = 'Pengawas Dinas',
            );
          });
          addedUserIds.add(du.userId);
        }
      }
    }

    return isar;
  }
}
