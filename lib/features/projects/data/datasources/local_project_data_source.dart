import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/database/hive_database_service.dart';
import '../../../../core/database/hive_models.dart';
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
  Future<List<ProjectMemberHive>> getProjectMembers(String projectId);
  Future<void> addProjectMember(String projectId, String userId, String role);
  Future<void> removeProjectMember(String projectId, String userId);
  Future<void> seedProjects();
}

class ProjectLocalDataSourceImpl implements ProjectLocalDataSource {
  @override
  Future<void> init() async {
    await HiveDatabaseService.initDb();
  }

  @override
  Future<List<String>> getProjectIdsForUser(String userId) async {
    final box = Hive.box<ProjectMemberHive>('projectMembers');
    return box.values.where((m) => m.userId == userId).map((m) => m.projectId).toList();
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
    final box = Hive.box<ProjectHive>('projects');

    List<String>? allowedProjectIds;
    if (userRole == 'kontraktor' && userId != null) {
      allowedProjectIds = await getProjectIdsForUser(userId);
      if (allowedProjectIds.isEmpty) return [];
    } else if (userRole == 'eksternal') {
      allowedProjectIds = ['project-1'];
    }

    var results = box.values.where((p) => p.isArchived == targetArchived);

    if (status != null && status.toLowerCase() != 'semua') {
      results = results.where((p) => p.status.toLowerCase() == status.toLowerCase());
    }

    if (search != null && search.isNotEmpty) {
      final s = search.toLowerCase();
      results = results.where((p) => 
        p.name.toLowerCase().contains(s) || 
        p.location.toLowerCase().contains(s)
      );
    }

    if (allowedProjectIds != null) {
      results = results.where((p) => allowedProjectIds!.contains(p.projectId));
    }

    return results.map((raw) => ProjectModel(
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
  Future<List<ProjectMemberHive>> getProjectMembers(String projectId) async {
    final box = Hive.box<ProjectMemberHive>('projectMembers');
    return box.values.where((m) => m.projectId == projectId).toList();
  }

  @override
  Future<void> addProjectMember(String projectId, String userId, String role) async {
    final box = Hive.box<ProjectMemberHive>('projectMembers');
    final existing = box.values.where((m) => m.projectId == projectId && m.userId == userId);
    if (existing.isNotEmpty) return;
    
    final member = ProjectMemberHive()
      ..projectId = projectId
      ..userId = userId
      ..role = role;
    await box.add(member);
  }

  @override
  Future<void> removeProjectMember(String projectId, String userId) async {
    final box = Hive.box<ProjectMemberHive>('projectMembers');
    final existing = box.values.where((m) => m.projectId == projectId && m.userId == userId);
    if (existing.isNotEmpty) {
      await existing.first.delete();
    }
  }

  @override
  Future<ProjectModel?> getProjectById(String id) async {
    final box = Hive.box<ProjectHive>('projects');
    final raw = box.get(id);
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
    final box = Hive.box<ProjectHive>('projects');
    final hiveProj = ProjectHive()
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
    await box.put(project.id, hiveProj);
  }

  @override
  Future<void> updateProject(ProjectModel project) async {
    await addProject(project); 
  }

  @override
  Future<void> deleteProject(String id) async {
    final box = Hive.box<ProjectHive>('projects');
    await box.delete(id);
  }

  @override
  Future<void> seedProjects() async {}
}
