import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:isar/isar.dart';
import '../../../core/database/isar_database_service.dart';
import '../../../core/database/isar_models.dart';
import '../../../core/enums/app_role.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../reports/presentation/report_controller.dart';
import '../../timeline/presentation/timeline_controller.dart';
import '../../notifications/presentation/notification_controller.dart';
import '../../timeline/data/models/timeline_model.dart';
import '../../notifications/data/models/notification_model.dart';
import '../data/datasources/local_project_data_source.dart';
import '../data/repositories/project_repository.dart';
import '../data/models/project_model.dart';
import '../data/datasources/local_document_data_source.dart';
import '../data/repositories/document_repository.dart';
import '../data/models/document_model.dart';
import '../data/models/folder_model.dart';
import '../../auth/data/models/user_model.dart';
import 'folder_controller.dart';

final contractRepositoryProvider = Provider<ContractRepository>((ref) {
  final dataSource = ContractLocalDataSourceImpl();
  return ContractRepositoryImpl(dataSource);
});

final contractsControllerProvider = StateNotifierProvider<ProjectsController, AsyncValue<List<ContractModel>>>((ref) {
  final repository = ref.watch(contractRepositoryProvider);
  return ProjectsController(repository, ref);
});

// Removed projectsWithProgressProvider as per Day 1 constraints: No parent-level progress calculation.
// UI should rely on contractsControllerProvider directly.

final projectsProvider = FutureProvider.family<List<ProjectModel>, String>((ref, contractId) async {
  final repository = ref.watch(contractRepositoryProvider);
  return repository.getProjects(contractId);
});

class ProjectsController extends StateNotifier<AsyncValue<List<ContractModel>>> {
  final ContractRepository _repository;
  final Ref _ref;

  ProjectsController(this._repository, this._ref) : super(const AsyncValue.data([]));

  Future<void> loadProjects({
    String? search,
    String? type,
    String? status,
    bool? isArchived,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.init();
      
      final authState = _ref.read(authControllerProvider);
      final user = authState.valueOrNull;
      final userRole = user?.role.name;
      final userId = user?.id;

      final projects = await _repository.getContracts(
        search: search,
        type: type,
        status: status,
        userRole: userRole,
        userId: userId,
        isArchived: isArchived,
      );
      state = AsyncValue.data(projects);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addContract(ContractModel project) async {
    state = const AsyncValue.loading();
    try {
      await _repository.addContract(project);
      
      // Create default folders for Parent Activity
      final defaultFolders = ['SPK', 'SPMK', 'Adendum Konsultan'];
      for (final folderName in defaultFolders) {
        await _ref.read(folderRepositoryProvider).addFolder(
          FolderModel(
            id: const Uuid().v4(),
            contractId: project.id,
            name: folderName,
            isDefault: true,
          ),
        );
      }
      
      await loadProjects();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateContract(ContractModel project) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateContract(project);
      await loadProjects();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteContract(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteContract(id);
      await loadProjects();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addMember(String projectId, String userId, String role) async {
    try {
      await _repository.addContractMember(projectId, userId, role);
      // Refresh member list
      _ref.invalidate(contractMembersProvider(projectId));
      // Refresh project list so UI reads updated owner/supervisor
      await loadProjects();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> removeMember(String projectId, String userId) async {
    try {
      await _repository.removeContractMember(projectId, userId);
      _ref.invalidate(contractMembersProvider(projectId));
      await loadProjects();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addProject(ProjectModel physicalActivity) async {
    try {
      await _repository.addProject(physicalActivity);

      // Create default folders for Physical Activity
      final defaultFolders = ['PCM', 'ADSET', 'Pelaksanaan Kegiatan', 'Laporan'];
      for (final folderName in defaultFolders) {
        await _ref.read(folderRepositoryProvider).addFolder(
          FolderModel(
            id: const Uuid().v4(),
            contractId: physicalActivity.contractId,
            projectId: physicalActivity.id,
            name: folderName,
            isDefault: true,
          ),
        );
      }
      
      _ref.invalidate(projectsProvider(physicalActivity.contractId));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Project Members Provider
// ─────────────────────────────────────────────────────────────

final contractMembersProvider = FutureProvider.family<List<ContractMemberIsar>, String>((ref, projectId) async {
  final isar = await IsarDatabaseService.db;
  return isar.contractMemberIsars.filter().contractIdEqualTo(projectId).findAll();
});

// ─────────────────────────────────────────────────────────────
// All Users Provider (for member selection)
// ─────────────────────────────────────────────────────────────

final allUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  final isar = await IsarDatabaseService.db;
  final rawUsers = await isar.userIsars.where().findAll();
  return rawUsers.map((u) => UserModel(
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

// ─────────────────────────────────────────────────────────────
// Document Providers & Notifiers
// ─────────────────────────────────────────────────────────────

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  final dataSource = DocumentLocalDataSourceImpl();
  return DocumentRepositoryImpl(dataSource);
});

final documentsControllerProvider = StateNotifierProvider<DocumentsController, AsyncValue<List<DocumentModel>>>((ref) {
  final repository = ref.watch(documentRepositoryProvider);
  return DocumentsController(repository, ref);
});

class DocumentsController extends StateNotifier<AsyncValue<List<DocumentModel>>> {
  final DocumentRepository _repository;
  final Ref _ref;

  DocumentsController(this._repository, this._ref) : super(const AsyncValue.data([]));

  Future<void> loadDocuments(String folderId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.init();
      // Instead of getting documents by contractId, get them by folderId
      final allDocs = await _repository.getDocuments(''); // We need to change the repo method
      // Wait, DocumentLocalDataSourceImpl expects projectId (contractId), which loads all docs for the activity.
      // So we can still load by contractId, but filter by folderId in UI, or we should update local_document_data_source to support querying by folderId directly.
      // Actually, since this is a simplified local DB, let's keep getDocuments(contractId) in the repo, but in the Controller we can filter if we want.
      // Let's modify DocumentLocalDataSourceImpl later to query by folderId. For now let's just pass folderId to a new repo method or change the existing one.
      // Assuming we change `getDocuments` to take `folderId`.
      final docs = await _repository.getDocuments(folderId);
      state = AsyncValue.data(docs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addDocument(DocumentModel document, String actorName, String actorRole) async {
    state = const AsyncValue.loading();
    try {
      await _repository.addDocument(document);
      
      // Log timeline
      final timelineItem = TimelineModel(
        id: const Uuid().v4(),
        title: 'Dokumen Ditambah',
        description: 'File "${document.name}" diunggah.',
        user: actorName,
        role: actorRole,
        icon: 'folder',
        createdAt: DateTime.now().toString().substring(0, 16),
      );
      await _ref.read(timelineRepositoryProvider).addTimeline(timelineItem);
      _ref.read(timelineControllerProvider.notifier).loadTimeline();

      // Send notification
      final notificationItem = NotificationModel(
        id: const Uuid().v4(),
        title: 'Dokumen Baru Diunggah',
        message: 'File "${document.name}" diunggah oleh $actorName ($actorRole).',
        type: 'Dokumen Baru',
        isRead: false,
        createdAt: DateTime.now().toString().substring(0, 16),
      );
      await _ref.read(notificationRepositoryProvider).addNotification(notificationItem);
      _ref.read(notificationsControllerProvider.notifier).loadNotifications();

      await loadDocuments(document.folderId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> renameDocument(String documentId, String newName, String actorName, String actorRole) async {
    state = const AsyncValue.loading();
    try {
      final list = state.valueOrNull ?? [];
      final doc = list.firstWhere((element) => element.id == documentId);
      final oldName = doc.name;
      final updated = doc.copyWith(name: newName);
      
      await _repository.updateDocument(updated);

      // Log timeline
      final timelineItem = TimelineModel(
        id: const Uuid().v4(),
        title: 'Dokumen Diubah Nama',
        description: 'File "$oldName" diubah namanya menjadi "$newName".',
        user: actorName,
        role: actorRole,
        icon: 'edit',
        createdAt: DateTime.now().toString().substring(0, 16),
      );
      await _ref.read(timelineRepositoryProvider).addTimeline(timelineItem);
      _ref.read(timelineControllerProvider.notifier).loadTimeline();

      await loadDocuments(doc.folderId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteDocument(String documentId, String actorName, String actorRole) async {
    state = const AsyncValue.loading();
    try {
      final list = state.valueOrNull ?? [];
      final doc = list.firstWhere((element) => element.id == documentId);
      
      await _repository.deleteDocument(documentId);

      // Remove timeline logging as per Day 2 requirement
      
      // We don't have the original folderId easily accessible here if we loaded by contractId, 
      // but if we changed loadDocuments to take folderId, we can reload with doc.folderId.
      await loadDocuments(doc.folderId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> uploadNewVersion(
      String documentId, String name, String fileSize, String fileUrl, String actorName, String actorRole) async {
    state = const AsyncValue.loading();
    try {
      final list = state.valueOrNull ?? [];
      final doc = list.firstWhere((element) => element.id == documentId);

      // Save old version to history list
      final oldVersionHistory = DocumentVersion(
        id: const Uuid().v4(),
        name: doc.name,
        fileUrl: doc.fileUrl,
        fileSize: doc.fileSize,
        uploadedBy: doc.uploadedBy,
        uploadedAt: doc.uploadedAt,
        version: doc.version,
      );

      final nextVersionNum = doc.version + 1;
      final updated = doc.copyWith(
        name: name,
        fileSize: fileSize,
        fileUrl: fileUrl,
        uploadedBy: actorName,
        uploadedAt: DateTime.now().toString().substring(0, 16),
        version: nextVersionNum,
        versions: [...doc.versions, oldVersionHistory],
      );

      await _repository.updateDocument(updated);

      // Log timeline
      final timelineItem = TimelineModel(
        id: const Uuid().v4(),
        title: 'Dokumen Versi Baru',
        description: 'Versi $nextVersionNum dari file "${doc.name}" diunggah oleh $actorName.',
        user: actorName,
        role: actorRole,
        icon: 'history',
        createdAt: DateTime.now().toString().substring(0, 16),
      );
      await _ref.read(timelineRepositoryProvider).addTimeline(timelineItem);
      _ref.read(timelineControllerProvider.notifier).loadTimeline();

      await loadDocuments(doc.folderId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Dashboard Statistics Provider (Queries Database Directly)
// ─────────────────────────────────────────────────────────────

final dashboardStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  // Watch other providers to trigger re-computation when data changes
  ref.watch(contractsControllerProvider);
  ref.watch(contractorReportsProvider);
  ref.watch(documentsControllerProvider);
  
  final authState = ref.watch(authControllerProvider);
  final user = authState.valueOrNull;
  final role = user?.role ?? AppRole.eksternal;

  final isar = await IsarDatabaseService.db;
  
  // Get accessible projects for the current user (same logic as LocalDataSource)
  List<ContractModel> allProjects = [];
  if (role == AppRole.kontraktor) {
    // We can just use the already loaded projects from contractsControllerProvider
    final projs = ref.watch(contractsControllerProvider).valueOrNull ?? [];
    allProjects = projs;
  } else {
    // Konsultan, Dinas, Eksternal see all
    final raw = await isar.contractIsars.filter().isArchivedEqualTo(false).findAll();
    allProjects = raw.map((p) => ContractModel(
      id: p.contractId, 
      type: p.type,
      name: p.name, 
      location: p.location, 
      status: p.status, 
      imageUrl: p.imageUrl, 
      description: p.description, 
      owner: p.owner, 
      supervisor: p.supervisor, 
      createdAt: p.createdAt,
      startDate: p.startDate,
      endDate: p.endDate,
      dinas: p.dinas,
      fundingSource: p.fundingSource,
      isArchived: p.isArchived,
    )).toList();
  }
  
  final allowedProjectIds = allProjects.map((p) => p.id).toSet();
  
  final totalProjects = allProjects.length;
  final activeProjects = allProjects.where((p) => p.status.toLowerCase() == 'progres').length;
  final completedProjects = allProjects.where((p) => p.status.toLowerCase() == 'selesai').length;
  
  // Actually we need the raw ActivityIsar objects to check endDate easily, or we can just parse it here.
  final todayStr = DateTime.now().toString().substring(0, 10);
  int lateProjects = 0;
  final rawProjects = await isar.contractIsars.where().findAll();
  for (var p in rawProjects) {
    if (allowedProjectIds.contains(p.contractId) && p.status.toLowerCase() == 'progres' && p.endDate.compareTo(todayStr) < 0) {
      lateProjects++;
    }
  }

  final allCReports = await isar.contractorReportIsars.where().findAll();
  final allSReports = await isar.supervisorReportIsars.where().findAll();
  
  // existing models still use projectId
  final myCReports = allCReports.where((r) => allowedProjectIds.contains(r.contractId)).toList();
  final mySReports = allSReports.where((r) => allowedProjectIds.contains(r.contractId)).toList();

  final totalReports = myCReports.length + mySReports.length;
  final pendingReports = myCReports.where((r) => r.status.toUpperCase() == 'MENUNGGU VERIFIKASI').length;
  final rejectedReports = myCReports.where((r) => r.status.toUpperCase() == 'DITOLAK').length;
  
  final totalDocuments = await isar.documentIsars.count();
  
  // Progress aggregation removed from parent Activity on Day 1
  final avgProgress = 0.0;
  final avgFinancialProgress = 0.0;

  return {
    'totalProjects': totalProjects,
    'activeProjects': activeProjects,
    'completedProjects': completedProjects,
    'lateProjects': lateProjects,
    'totalReports': totalReports,
    'pendingReports': pendingReports,
    'rejectedReports': rejectedReports,
    'totalDocuments': totalDocuments,
    'avgProgress': avgProgress,
    'avgFinancialProgress': avgFinancialProgress,
  };
});
