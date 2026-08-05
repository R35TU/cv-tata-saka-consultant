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
import '../data/datasources/firebase_project_data_source.dart';
import '../data/repositories/project_repository.dart';
import '../data/models/project_model.dart';
import '../data/datasources/local_document_data_source.dart';
import '../data/repositories/document_repository.dart';
import '../data/models/document_model.dart';
import '../../../backend/models/user_model.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final dataSource = ProjectFirebaseDataSourceImpl();
  return ProjectRepositoryImpl(dataSource);
});

final projectsControllerProvider = StateNotifierProvider<ProjectsController, AsyncValue<List<ProjectModel>>>((ref) {
  final repository = ref.watch(projectRepositoryProvider);
  return ProjectsController(repository, ref);
});

class ProjectsController extends StateNotifier<AsyncValue<List<ProjectModel>>> {
  final ProjectRepository _repository;
  final Ref _ref;

  ProjectsController(this._repository, this._ref) : super(const AsyncValue.data([]));

  Future<void> loadProjects({
    String? search,
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

      final projects = await _repository.getProjects(
        search: search,
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

  Future<void> addProject(ProjectModel project) async {
    state = const AsyncValue.loading();
    try {
      await _repository.addProject(project);
      await loadProjects();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateProjectProgress(String projectId, double newProgress) async {
    state = const AsyncValue.loading();
    try {
      final project = await _repository.getProjectById(projectId);
      if (project != null) {
        final updated = project.copyWith(
          physicalProgress: newProgress,
          status: newProgress >= 1.0 ? 'Selesai' : project.status,
        );
        await _repository.updateProject(updated);
      }
      await loadProjects();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteProject(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteProject(id);
      await loadProjects();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addMember(String projectId, String userId, String role) async {
    try {
      await _repository.addProjectMember(projectId, userId, role);
      // Refresh member list
      _ref.invalidate(projectMembersProvider(projectId));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> removeMember(String projectId, String userId) async {
    try {
      await _repository.removeProjectMember(projectId, userId);
      _ref.invalidate(projectMembersProvider(projectId));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Project Members Provider
// ─────────────────────────────────────────────────────────────

final projectMembersProvider = FutureProvider.family<List<ProjectMemberIsar>, String>((ref, projectId) async {
  final isar = await IsarDatabaseService.db;
  return isar.projectMemberIsars.filter().projectIdEqualTo(projectId).findAll();
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
    email: u.email,
    role: AppRole.fromString(u.role),
    username: u.username,
    nomorHp: u.phone,
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

  Future<void> loadDocuments(String projectId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.init();
      final docs = await _repository.getDocuments(projectId);
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
        description: 'File "${document.name}" diunggah ke folder "${document.folderName}".',
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

      await loadDocuments(document.projectId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> renameDocument(String projectId, String documentId, String newName, String actorName, String actorRole) async {
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

      await loadDocuments(projectId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteDocument(String projectId, String documentId, String actorName, String actorRole) async {
    state = const AsyncValue.loading();
    try {
      final list = state.valueOrNull ?? [];
      final doc = list.firstWhere((element) => element.id == documentId);
      
      await _repository.deleteDocument(documentId);

      // Log timeline
      final timelineItem = TimelineModel(
        id: const Uuid().v4(),
        title: 'Dokumen Dihapus',
        description: 'File "${doc.name}" dihapus dari folder "${doc.folderName}".',
        user: actorName,
        role: actorRole,
        icon: 'delete',
        createdAt: DateTime.now().toString().substring(0, 16),
      );
      await _ref.read(timelineRepositoryProvider).addTimeline(timelineItem);
      _ref.read(timelineControllerProvider.notifier).loadTimeline();

      await loadDocuments(projectId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> uploadNewVersion(
      String projectId, String documentId, String name, String fileSize, String fileUrl, String actorName, String actorRole) async {
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

      await loadDocuments(projectId);
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
  ref.watch(projectsControllerProvider);
  ref.watch(contractorReportsProvider);
  ref.watch(documentsControllerProvider);

  final isar = await IsarDatabaseService.db;
  
  final totalProjects = await isar.projectIsars.count();
  final activeProjects = await isar.projectIsars.filter().statusEqualTo('Progres', caseSensitive: false).count();
  final completedProjects = await isar.projectIsars.filter().statusEqualTo('Selesai', caseSensitive: false).count();
  
  final today = DateTime.now().toString().substring(0, 10);
  final lateProjects = await isar.projectIsars.filter()
      .statusEqualTo('Progres', caseSensitive: false)
      .and()
      .endDateLessThan(today)
      .count();

  final totalReports = await isar.contractorReportIsars.count() + await isar.supervisorReportIsars.count();
  final pendingReports = await isar.contractorReportIsars.filter().statusEqualTo('MENUNGGU VERIFIKASI', caseSensitive: false).count();
  final rejectedReports = await isar.contractorReportIsars.filter().statusEqualTo('DITOLAK', caseSensitive: false).count();
  
  final totalDocuments = await isar.documentIsars.count();
  
  final allProjects = await isar.projectIsars.where().findAll();
  final avgProgress = allProjects.isEmpty 
      ? 0.0 
      : allProjects.map((p) => p.physicalProgress).reduce((a, b) => a + b) / allProjects.length;

  final avgFinancialProgress = allProjects.isEmpty 
      ? 0.0 
      : allProjects.map((p) => p.financialProgress).reduce((a, b) => a + b) / allProjects.length;

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
