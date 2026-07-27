import 'package:isar/isar.dart';
import '../../../../core/database/isar_database_service.dart';
import '../../../../core/database/isar_models.dart';
import '../models/project_model.dart';

abstract class ProjectLocalDataSource {
  Future<void> init();
  Future<List<ProjectModel>> getProjects({
    String? search,
    String? status,
    String? userRole,
    String? userId,
    bool? isArchived,
  });
  Future<List<String>> getProjectIdsForUser(String userId);
  Future<ProjectModel?> getProjectById(String id);
  Future<void> addProject(ProjectModel project);
  Future<void> updateProject(ProjectModel project);
  Future<void> deleteProject(String id);
  Future<List<ProjectMemberIsar>> getProjectMembers(String projectId);
  Future<void> addProjectMember(String projectId, String userId, String role);
  Future<void> removeProjectMember(String projectId, String userId);
  Future<void> seedProjects();
}

class ProjectLocalDataSourceImpl implements ProjectLocalDataSource {
  Isar? _db;

  Future<Isar> get db async {
    if (_db != null) return _db!;
    _db = await IsarDatabaseService.db;
    return _db!;
  }

  @override
  Future<void> init() async {
    await db;
  }

  @override
  Future<List<String>> getProjectIdsForUser(String userId) async {
    final database = await db;
    final members = await database.projectMemberIsars
        .filter()
        .userIdEqualTo(userId)
        .findAll();
    return members.map((m) => m.projectId).toList();
  }

  @override
  Future<List<ProjectModel>> getProjects({
    String? search,
    String? status,
    String? userRole,
    String? userId,
    bool? isArchived,
  }) async {
    final targetArchived = isArchived ?? false;
    final database = await db;

    // Role-based: kontraktor only sees projects they are a member of
    List<String>? allowedProjectIds;
    if (userRole == 'kontraktor' && userId != null) {
      allowedProjectIds = await getProjectIdsForUser(userId);
      if (allowedProjectIds.isEmpty) return [];
    } else if (userRole == 'eksternal') {
      // Eksternal can only see specific public projects
      allowedProjectIds = ['project-1'];
    }
    // konsultan & dinas can see all projects

    var query = database.projectIsars.filter().isArchivedEqualTo(targetArchived);

    if (status != null && status.toLowerCase() != 'semua') {
      query = query.statusEqualTo(status, caseSensitive: false);
    }

    if (search != null && search.isNotEmpty) {
      query = query.group((q) => q
        .nameContains(search, caseSensitive: false)
        .or()
        .locationContains(search, caseSensitive: false)
      );
    }

    final list = await query.findAll();

    // Filter by allowed project IDs if applicable
    final filtered = allowedProjectIds != null
        ? list.where((p) => allowedProjectIds!.contains(p.projectId)).toList()
        : list;

    return filtered.map((raw) => ProjectModel(
      id: raw.projectId,
      name: raw.name,
      location: raw.location,
      status: raw.status,
      physicalProgress: raw.physicalProgress,
      financialProgress: raw.financialProgress,
      imageUrl: raw.imageUrl,
      description: raw.description,
      owner: raw.owner,
      supervisor: raw.supervisor,
      createdAt: raw.createdAt,
      startDate: raw.startDate,
      endDate: raw.endDate,
      ownerDetail: raw.ownerDetail,
      fundingSource: raw.fundingSource,
      isArchived: raw.isArchived,
    )).toList();
  }

  @override
  Future<List<ProjectMemberIsar>> getProjectMembers(String projectId) async {
    final database = await db;
    return database.projectMemberIsars
        .filter()
        .projectIdEqualTo(projectId)
        .findAll();
  }

  @override
  Future<void> addProjectMember(String projectId, String userId, String role) async {
    final database = await db;
    // Check if already a member
    final existing = await database.projectMemberIsars
        .filter()
        .projectIdEqualTo(projectId)
        .and()
        .userIdEqualTo(userId)
        .findFirst();
    if (existing != null) return; // already a member
    await database.writeTxn(() async {
      final member = ProjectMemberIsar()
        ..projectId = projectId
        ..userId = userId
        ..role = role;
      await database.projectMemberIsars.put(member);
    });
  }

  @override
  Future<void> removeProjectMember(String projectId, String userId) async {
    final database = await db;
    final existing = await database.projectMemberIsars
        .filter()
        .projectIdEqualTo(projectId)
        .and()
        .userIdEqualTo(userId)
        .findFirst();
    if (existing != null) {
      await database.writeTxn(() async {
        await database.projectMemberIsars.delete(existing.id);
      });
    }
  }

  @override
  Future<ProjectModel?> getProjectById(String id) async {
    final database = await db;
    final raw = await database.projectIsars.filter().projectIdEqualTo(id).findFirst();
    if (raw == null) return null;
    return ProjectModel(
      id: raw.projectId,
      name: raw.name,
      location: raw.location,
      status: raw.status,
      physicalProgress: raw.physicalProgress,
      financialProgress: raw.financialProgress,
      imageUrl: raw.imageUrl,
      description: raw.description,
      owner: raw.owner,
      supervisor: raw.supervisor,
      createdAt: raw.createdAt,
      startDate: raw.startDate,
      endDate: raw.endDate,
      ownerDetail: raw.ownerDetail,
      fundingSource: raw.fundingSource,
      isArchived: raw.isArchived,
    );
  }

  @override
  Future<void> addProject(ProjectModel project) async {
    final database = await db;
    await database.writeTxn(() async {
      final isarProj = ProjectIsar()
        ..projectId = project.id
        ..name = project.name
        ..location = project.location
        ..status = project.status
        ..physicalProgress = project.physicalProgress
        ..financialProgress = project.financialProgress
        ..imageUrl = project.imageUrl
        ..description = project.description
        ..owner = project.owner
        ..supervisor = project.supervisor
        ..createdAt = project.createdAt
        ..startDate = project.startDate
        ..endDate = project.endDate
        ..ownerDetail = project.ownerDetail
        ..fundingSource = project.fundingSource
        ..isArchived = project.isArchived;
      await database.projectIsars.put(isarProj);
    });
  }

  @override
  Future<void> updateProject(ProjectModel project) async {
    final database = await db;
    final existing = await database.projectIsars.filter().projectIdEqualTo(project.id).findFirst();
    await database.writeTxn(() async {
      final isarProj = (existing ?? ProjectIsar())
        ..projectId = project.id
        ..name = project.name
        ..location = project.location
        ..status = project.status
        ..physicalProgress = project.physicalProgress
        ..financialProgress = project.financialProgress
        ..imageUrl = project.imageUrl
        ..description = project.description
        ..owner = project.owner
        ..supervisor = project.supervisor
        ..createdAt = project.createdAt
        ..startDate = project.startDate
        ..endDate = project.endDate
        ..ownerDetail = project.ownerDetail
        ..fundingSource = project.fundingSource
        ..isArchived = project.isArchived;
      await database.projectIsars.put(isarProj);
    });
  }

  @override
  Future<void> deleteProject(String id) async {
    final database = await db;
    final existing = await database.projectIsars.filter().projectIdEqualTo(id).findFirst();
    if (existing != null) {
      await database.writeTxn(() async {
        await database.projectIsars.delete(existing.id);
      });
    }
  }

  @override
  Future<void> seedProjects() async {
    // Already handled in IsarDatabaseService
  }
}
