import 'package:isar/isar.dart';
import '../../../../core/database/isar_database_service.dart';
import '../../../../core/database/isar_models.dart';
import '../models/folder_model.dart';

abstract class FolderLocalDataSource {
  Future<void> init();
  Future<List<FolderModel>> getFolders(String contractId, {String? projectId});
  Future<void> addFolder(FolderModel folder);
  Future<void> updateFolder(FolderModel folder);
  Future<void> deleteFolder(String folderId);
}

class FolderLocalDataSourceImpl implements FolderLocalDataSource {
  late Isar _database;
  bool _isInitialized = false;

  @override
  Future<void> init() async {
    if (!_isInitialized) {
      _database = await IsarDatabaseService.db;
      _isInitialized = true;
    }
  }

  FolderModel _mapToModel(FolderIsar isar) {
    return FolderModel(
      id: isar.folderId,
      contractId: isar.contractId,
      projectId: isar.projectId,
      name: isar.name,
      isDefault: isar.isDefault,
    );
  }

  FolderIsar _mapToIsar(FolderModel model) {
    return FolderIsar()
      ..folderId = model.id
      ..contractId = model.contractId
      ..projectId = model.projectId
      ..name = model.name
      ..isDefault = model.isDefault;
  }

  @override
  Future<List<FolderModel>> getFolders(String contractId, {String? projectId}) async {
    await init();
    
    // We must query according to the exact context (to avoid leakage).
    List<FolderIsar> isarFolders;
    if (projectId == null) {
      // Parent Activity folders
      isarFolders = await _database.folderIsars
          .filter()
          .contractIdEqualTo(contractId)
          .and()
          .projectIdIsNull()
          .findAll();
    } else {
      // Physical Activity folders
      isarFolders = await _database.folderIsars
          .filter()
          .contractIdEqualTo(contractId)
          .and()
          .projectIdEqualTo(projectId)
          .findAll();
    }
    
    return isarFolders.map(_mapToModel).toList();
  }

  @override
  Future<void> addFolder(FolderModel folder) async {
    await init();
    
    // Make folder creation idempotent
    List<FolderIsar> existing;
    if (folder.projectId == null) {
        existing = await _database.folderIsars.filter()
            .contractIdEqualTo(folder.contractId)
            .and()
            .projectIdIsNull()
            .and()
            .nameEqualTo(folder.name)
            .findAll();
    } else {
        existing = await _database.folderIsars.filter()
            .contractIdEqualTo(folder.contractId)
            .and()
            .projectIdEqualTo(folder.projectId)
            .and()
            .nameEqualTo(folder.name)
            .findAll();
    }

    if (existing.isNotEmpty) {
        return; // Already exists, skip creation
    }

    final isarObj = _mapToIsar(folder);
    await _database.writeTxn(() async {
      await _database.folderIsars.put(isarObj);
    });
  }

  @override
  Future<void> updateFolder(FolderModel folder) async {
    await init();
    final isarObj = _mapToIsar(folder);
    
    await _database.writeTxn(() async {
      final existing = await _database.folderIsars.filter().folderIdEqualTo(folder.id).findFirst();
      if (existing != null) {
        isarObj.id = existing.id; // Keep same Isar auto-increment id
        await _database.folderIsars.put(isarObj);
      }
    });
  }

  @override
  Future<void> deleteFolder(String folderId) async {
    await init();
    await _database.writeTxn(() async {
      final existing = await _database.folderIsars.filter().folderIdEqualTo(folderId).findFirst();
      if (existing != null) {
        await _database.folderIsars.delete(existing.id);
        final docs = await _database.documentIsars.filter().folderIdEqualTo(folderId).findAll();
        for (final doc in docs) {
          await _database.documentIsars.delete(doc.id);
        }
      }
    });
  }
}
