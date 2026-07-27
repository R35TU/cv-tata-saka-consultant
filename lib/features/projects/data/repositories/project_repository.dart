import '../../../../core/database/isar_models.dart';
import '../datasources/local_project_data_source.dart';
import '../models/project_model.dart';

abstract class ProjectRepository {
  Future<void> init();
  Future<List<ProjectModel>> getProjects({
    String? search,
    String? status,
    String? userRole,
    String? userId,
    bool? isArchived,
  });
  Future<ProjectModel?> getProjectById(String id);
  Future<void> addProject(ProjectModel project);
  Future<void> updateProject(ProjectModel project);
  Future<void> deleteProject(String id);
  Future<List<ProjectMemberIsar>> getProjectMembers(String projectId);
  Future<void> addProjectMember(String projectId, String userId, String role);
  Future<void> removeProjectMember(String projectId, String userId);
}

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectLocalDataSource localDataSource;

  ProjectRepositoryImpl(this.localDataSource);

  @override
  Future<void> init() => localDataSource.init();

  @override
  Future<List<ProjectModel>> getProjects({
    String? search,
    String? status,
    String? userRole,
    String? userId,
    bool? isArchived,
  }) => localDataSource.getProjects(
    search: search,
    status: status,
    userRole: userRole,
    userId: userId,
    isArchived: isArchived,
  );

  @override
  Future<ProjectModel?> getProjectById(String id) => localDataSource.getProjectById(id);

  @override
  Future<void> addProject(ProjectModel project) => localDataSource.addProject(project);

  @override
  Future<void> updateProject(ProjectModel project) => localDataSource.updateProject(project);

  @override
  Future<void> deleteProject(String id) => localDataSource.deleteProject(id);

  @override
  Future<List<ProjectMemberIsar>> getProjectMembers(String projectId) =>
      localDataSource.getProjectMembers(projectId);

  @override
  Future<void> addProjectMember(String projectId, String userId, String role) =>
      localDataSource.addProjectMember(projectId, userId, role);

  @override
  Future<void> removeProjectMember(String projectId, String userId) =>
      localDataSource.removeProjectMember(projectId, userId);
}
