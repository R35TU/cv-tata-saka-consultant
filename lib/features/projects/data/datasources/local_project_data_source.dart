import 'package:isar/isar.dart';
import '../../../../core/database/isar_database_service.dart';
import '../../../../core/database/isar_models.dart';
import '../models/project_model.dart';

abstract class ContractLocalDataSource {
  Future<void> init();
  Future<List<ContractModel>> getContracts({
    String? search,
    String? type,
    String? status,
    String? userRole,
    String? userId,
    bool? isArchived,
  });
  Future<List<String>> getProjectIdsForUser(String userId);
  Future<ContractModel?> getContractById(String id);
  Future<void> addContract(ContractModel project);
  Future<void> updateContract(ContractModel project);
  Future<void> deleteContract(String id);

  Future<List<ProjectModel>> getProjects(String contractId);
  Future<ProjectModel?> getProjectById(String id);
  Future<void> addProject(ProjectModel physicalActivity);
  Future<void> updateProject(ProjectModel physicalActivity);
  Future<void> deleteProject(String id);

  Future<List<ContractMemberIsar>> getContractMembers(String contractId);
  Future<void> addContractMember(String contractId, String userId, String role);
  Future<void> removeContractMember(String contractId, String userId);
  Future<void> seedProjects();
}

class ContractLocalDataSourceImpl implements ContractLocalDataSource {
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
    final members = await database.contractMemberIsars
        .filter()
        .userIdEqualTo(userId)
        .findAll();
    return members.map((m) => m.contractId).toList();
  }

  @override
  Future<List<ContractModel>> getContracts({
    String? search,
    String? type,
    String? status,
    String? userRole,
    String? userId,
    bool? isArchived,
  }) async {
    final targetArchived = isArchived ?? false;
    final database = await db;

    List<String>? allowedcontractIds;
    if (userRole == 'kontraktor' && userId != null) {
      final userObj = await database.userIsars.filter().userIdEqualTo(userId).findFirst();
      final userName = userObj?.name ?? '';
      final membercontractIds = await getProjectIdsForUser(userId);
      final allActivities = await database.contractIsars.filter().isArchivedEqualTo(targetArchived).findAll();
      allowedcontractIds = allActivities
          .where((p) => (userName.isNotEmpty && p.owner == userName) || membercontractIds.contains(p.contractId))
          .map((p) => p.contractId)
          .toList();
      if (allowedcontractIds.isEmpty) return [];
    }

    var query = database.contractIsars.filter().isArchivedEqualTo(targetArchived);

    if (type != null && type.toLowerCase() != 'semua') {
      query = query.typeEqualTo(type);
    }

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

    final filtered = allowedcontractIds != null
        ? list.where((p) => allowedcontractIds!.contains(p.contractId)).toList()
        : list;

    return filtered.map((raw) => ContractModel(
      id: raw.contractId,
      type: raw.type,
      name: raw.name,
      location: raw.location,
      status: raw.status,
      imageUrl: raw.imageUrl,
      description: raw.description,
      owner: raw.owner,
      supervisor: raw.supervisor,
      createdAt: raw.createdAt,
      startDate: raw.startDate,
      endDate: raw.endDate,
      dinas: raw.dinas,
      fundingSource: raw.fundingSource,
      isArchived: raw.isArchived,
    )).toList();
  }

  @override
  Future<List<ContractMemberIsar>> getContractMembers(String contractId) async {
    final database = await db;
    return database.contractMemberIsars
        .filter()
        .contractIdEqualTo(contractId)
        .findAll();
  }

  @override
  Future<void> addContractMember(String contractId, String userId, String role) async {
    final database = await db;
    final existing = await database.contractMemberIsars
        .filter()
        .contractIdEqualTo(contractId)
        .and()
        .userIdEqualTo(userId)
        .findFirst();
    if (existing != null) return;
    
    final user = await database.userIsars.filter().userIdEqualTo(userId).findFirst();
    
    await database.writeTxn(() async {
      final member = ContractMemberIsar()
        ..contractId = contractId
        ..userId = userId
        ..role = role;
      await database.contractMemberIsars.put(member);
      
      if (user != null) {
        final act = await database.contractIsars.filter().contractIdEqualTo(contractId).findFirst();
        if (act != null) {
          bool updated = false;
          if (role == 'Pelaksana') {
            act.owner = user.name;
            updated = true;
          } else if (role == 'Pengawas') {
            act.supervisor = user.name;
            updated = true;
          }
          if (updated) {
            await database.contractIsars.put(act);
          }
        }
      }
    });
  }

  @override
  Future<void> removeContractMember(String contractId, String userId) async {
    final database = await db;
    final existing = await database.contractMemberIsars
        .filter()
        .contractIdEqualTo(contractId)
        .and()
        .userIdEqualTo(userId)
        .findFirst();
    if (existing != null) {
      await database.writeTxn(() async {
        await database.contractMemberIsars.delete(existing.id);
        
        final act = await database.contractIsars.filter().contractIdEqualTo(contractId).findFirst();
        if (act != null) {
          bool updated = false;
          if (existing.role == 'Pelaksana') {
            act.owner = '';
            updated = true;
          } else if (existing.role == 'Pengawas') {
            act.supervisor = '';
            updated = true;
          }
          if (updated) {
            await database.contractIsars.put(act);
          }
        }
      });
    }
  }

  @override
  Future<ContractModel?> getContractById(String id) async {
    final database = await db;
    final raw = await database.contractIsars.filter().contractIdEqualTo(id).findFirst();
    if (raw == null) return null;
    return ContractModel(
      id: raw.contractId,
      type: raw.type,
      name: raw.name,
      location: raw.location,
      status: raw.status,
      imageUrl: raw.imageUrl,
      description: raw.description,
      owner: raw.owner,
      supervisor: raw.supervisor,
      createdAt: raw.createdAt,
      startDate: raw.startDate,
      endDate: raw.endDate,
      dinas: raw.dinas,
      fundingSource: raw.fundingSource,
      isArchived: raw.isArchived,
    );
  }

  Future<void> _syncProjectMembers(Isar database, ContractModel project) async {
    final allUsers = await database.userIsars.where().findAll();

    final Map<String, String> targets = {};

    if (project.owner.isNotEmpty) {
      final ownerUser = allUsers.where((u) => u.name == project.owner).firstOrNull;
      if (ownerUser != null) targets[ownerUser.userId] = 'Pelaksana';
    }

    if (project.supervisor.isNotEmpty) {
      final supervisorUser = allUsers.where((u) => u.name == project.supervisor).firstOrNull;
      if (supervisorUser != null && !targets.containsKey(supervisorUser.userId)) {
        targets[supervisorUser.userId] = 'Pengawas';
      }
    }

    for (final ku in allUsers.where((u) => u.role == 'konsultan')) {
      if (!targets.containsKey(ku.userId)) targets[ku.userId] = 'Pengawas';
    }

    for (final du in allUsers.where((u) => u.role == 'dinas')) {
      if (!targets.containsKey(du.userId)) targets[du.userId] = 'Pengawas Dinas';
    }

    final existing = await database.contractMemberIsars
        .filter().contractIdEqualTo(project.id).findAll();
    for (final old in existing) {
      await database.writeTxn(() => database.contractMemberIsars.delete(old.id));
    }

    for (final entry in targets.entries) {
      await database.writeTxn(() async {
        await database.contractMemberIsars.put(
          ContractMemberIsar()
            ..contractId = project.id
            ..userId = entry.key
            ..role = entry.value,
        );
      });
    }
  }


  @override
  Future<void> addContract(ContractModel project) async {
    final database = await db;
    await database.writeTxn(() async {
      final isarProj = ContractIsar()
        ..contractId = project.id
        ..type = project.type
        ..name = project.name
        ..location = project.location
        ..status = project.status
        ..imageUrl = project.imageUrl
        ..description = project.description
        ..owner = project.owner
        ..supervisor = project.supervisor
        ..createdAt = project.createdAt
        ..startDate = project.startDate
        ..endDate = project.endDate
        ..dinas = project.dinas
        ..fundingSource = project.fundingSource
        ..isArchived = project.isArchived;
      await database.contractIsars.put(isarProj);
    });
    await _syncProjectMembers(database, project);
  }

  @override
  Future<void> updateContract(ContractModel project) async {
    final database = await db;
    final existing = await database.contractIsars
        .filter()
        .contractIdEqualTo(project.id)
        .findFirst();
    await database.writeTxn(() async {
      final isarProj = (existing ?? ContractIsar())
        ..contractId = project.id
        ..type = project.type
        ..name = project.name
        ..location = project.location
        ..status = project.status
        ..imageUrl = project.imageUrl
        ..description = project.description
        ..owner = project.owner
        ..supervisor = project.supervisor
        ..createdAt = project.createdAt
        ..startDate = project.startDate
        ..endDate = project.endDate
        ..dinas = project.dinas
        ..fundingSource = project.fundingSource
        ..isArchived = project.isArchived;
      await database.contractIsars.put(isarProj);
    });
    await _syncProjectMembers(database, project);
  }

  @override
  Future<void> deleteContract(String id) async {
    final database = await db;
    final existing = await database.contractIsars.filter().contractIdEqualTo(id).findFirst();
    if (existing != null) {
      await database.writeTxn(() async {
        await database.contractIsars.delete(existing.id);
      });
    }
  }
  
  @override
  Future<List<ProjectModel>> getProjects(String contractId) async {
    final database = await db;
    final list = await database.projectIsars.filter().contractIdEqualTo(contractId).findAll();
    return list.map((raw) => ProjectModel(
      id: raw.projectId,
      contractId: raw.contractId,
      name: raw.name,
      location: raw.location,
      contractor: raw.contractor,
      description: raw.description,
      status: raw.status,
      physicalProgress: raw.physicalProgress,
      financialProgress: raw.financialProgress,
    )).toList();
  }
  
  @override
  Future<ProjectModel?> getProjectById(String id) async {
    final database = await db;
    final raw = await database.projectIsars.filter().projectIdEqualTo(id).findFirst();
    if (raw == null) return null;
    return ProjectModel(
      id: raw.projectId,
      contractId: raw.contractId,
      name: raw.name,
      location: raw.location,
      contractor: raw.contractor,
      description: raw.description,
      status: raw.status,
      physicalProgress: raw.physicalProgress,
      financialProgress: raw.financialProgress,
    );
  }
  
  @override
  Future<void> addProject(ProjectModel physicalActivity) async {
    final database = await db;
    await database.writeTxn(() async {
      final isarPhys = ProjectIsar()
        ..projectId = physicalActivity.id
        ..contractId = physicalActivity.contractId
        ..name = physicalActivity.name
        ..location = physicalActivity.location
        ..contractor = physicalActivity.contractor
        ..description = physicalActivity.description
        ..status = physicalActivity.status
        ..physicalProgress = physicalActivity.physicalProgress
        ..financialProgress = physicalActivity.financialProgress;
      await database.projectIsars.put(isarPhys);
    });
  }
  
  @override
  Future<void> updateProject(ProjectModel physicalActivity) async {
    final database = await db;
    final existing = await database.projectIsars
        .filter()
        .projectIdEqualTo(physicalActivity.id)
        .findFirst();
    await database.writeTxn(() async {
      final isarPhys = (existing ?? ProjectIsar())
        ..projectId = physicalActivity.id
        ..contractId = physicalActivity.contractId
        ..name = physicalActivity.name
        ..location = physicalActivity.location
        ..contractor = physicalActivity.contractor
        ..description = physicalActivity.description
        ..status = physicalActivity.status
        ..physicalProgress = physicalActivity.physicalProgress
        ..financialProgress = physicalActivity.financialProgress;
      await database.projectIsars.put(isarPhys);
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
