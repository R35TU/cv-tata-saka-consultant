import '../../../../core/database/isar_models.dart';
import '../datasources/local_project_data_source.dart';
import '../models/project_model.dart';

abstract class ContractRepository {
  Future<void> init();
  
  // Activities
  Future<List<ContractModel>> getContracts({
    String? search,
    String? type,
    String? status,
    String? userRole,
    String? userId,
    bool? isArchived,
  });
  Future<ContractModel?> getContractById(String id);
  Future<void> addContract(ContractModel project);
  Future<void> updateContract(ContractModel project);
  Future<void> deleteContract(String id);
  
  // Physical Activities
  Future<List<ProjectModel>> getProjects(String contractId);
  Future<ProjectModel?> getProjectById(String id);
  Future<void> addProject(ProjectModel physicalActivity);
  Future<void> updateProject(ProjectModel physicalActivity);
  Future<void> deleteProject(String id);

  // Members
  Future<List<ContractMemberIsar>> getContractMembers(String contractId);
  Future<void> addContractMember(String contractId, String userId, String role);
  Future<void> removeContractMember(String contractId, String userId);
}

class ContractRepositoryImpl implements ContractRepository {
  final ContractLocalDataSource localDataSource;

  ContractRepositoryImpl(this.localDataSource);

  @override
  Future<void> init() => localDataSource.init();

  @override
  Future<List<ContractModel>> getContracts({
    String? search,
    String? type,
    String? status,
    String? userRole,
    String? userId,
    bool? isArchived,
  }) => localDataSource.getContracts(
    search: search,
    type: type,
    status: status,
    userRole: userRole,
    userId: userId,
    isArchived: isArchived,
  );

  @override
  Future<ContractModel?> getContractById(String id) => localDataSource.getContractById(id);

  @override
  Future<void> addContract(ContractModel project) => localDataSource.addContract(project);

  @override
  Future<void> updateContract(ContractModel project) => localDataSource.updateContract(project);

  @override
  Future<void> deleteContract(String id) => localDataSource.deleteContract(id);

  @override
  Future<List<ProjectModel>> getProjects(String contractId) => localDataSource.getProjects(contractId);

  @override
  Future<ProjectModel?> getProjectById(String id) => localDataSource.getProjectById(id);

  @override
  Future<void> addProject(ProjectModel physicalActivity) => localDataSource.addProject(physicalActivity);

  @override
  Future<void> updateProject(ProjectModel physicalActivity) => localDataSource.updateProject(physicalActivity);

  @override
  Future<void> deleteProject(String id) => localDataSource.deleteProject(id);

  @override
  Future<List<ContractMemberIsar>> getContractMembers(String contractId) =>
      localDataSource.getContractMembers(contractId);

  @override
  Future<void> addContractMember(String contractId, String userId, String role) =>
      localDataSource.addContractMember(contractId, userId, role);

  @override
  Future<void> removeContractMember(String contractId, String userId) =>
      localDataSource.removeContractMember(contractId, userId);
}
