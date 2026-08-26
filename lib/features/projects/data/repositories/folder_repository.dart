import '../datasources/local_folder_data_source.dart';
import '../models/folder_model.dart';

abstract class FolderRepository {
  Future<void> init();
  Future<List<FolderModel>> getFolders(String activityId, {String? projectId});
  Future<void> addFolder(FolderModel folder);
  Future<void> updateFolder(FolderModel folder);
  Future<void> deleteFolder(String folderId);
}

class FolderRepositoryImpl implements FolderRepository {
  final FolderLocalDataSource dataSource;

  FolderRepositoryImpl(this.dataSource);

  @override
  Future<void> init() async {
    await dataSource.init();
  }

  @override
  Future<List<FolderModel>> getFolders(String activityId, {String? projectId}) async {
    return dataSource.getFolders(activityId, projectId: projectId);
  }

  @override
  Future<void> addFolder(FolderModel folder) async {
    return dataSource.addFolder(folder);
  }

  @override
  Future<void> updateFolder(FolderModel folder) async {
    return dataSource.updateFolder(folder);
  }

  @override
  Future<void> deleteFolder(String folderId) async {
    return dataSource.deleteFolder(folderId);
  }
}
