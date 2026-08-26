import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/datasources/local_folder_data_source.dart';
import '../data/repositories/folder_repository.dart';
import '../data/models/folder_model.dart';

final folderRepositoryProvider = Provider<FolderRepository>((ref) {
  final dataSource = FolderLocalDataSourceImpl();
  return FolderRepositoryImpl(dataSource);
});

// A family provider to load folders for a specific context
// contextId format: 'contractId' or 'contractId:projectId'
final foldersControllerProvider = StateNotifierProvider.family<FoldersController, AsyncValue<List<FolderModel>>, String>((ref, contextId) {
  final repository = ref.watch(folderRepositoryProvider);
  return FoldersController(repository, contextId);
});

class FoldersController extends StateNotifier<AsyncValue<List<FolderModel>>> {
  final FolderRepository _repository;
  final String contextId; // "contractId" or "contractId:projectId"

  FoldersController(this._repository, this.contextId) : super(const AsyncValue.loading()) {
    loadFolders();
  }

  String get _contractId {
    if (contextId.contains(':')) {
      return contextId.split(':')[0];
    }
    return contextId;
  }

  String? get _projectId {
    if (contextId.contains(':')) {
      return contextId.split(':')[1];
    }
    return null;
  }

  Future<void> loadFolders() async {
    state = const AsyncValue.loading();
    try {
      await _repository.init();
      final folders = await _repository.getFolders(_contractId, projectId: _projectId);
      state = AsyncValue.data(folders);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addFolder(String name, {bool isDefault = false}) async {
    state = const AsyncValue.loading();
    try {
      final newFolder = FolderModel(
        id: const Uuid().v4(),
        contractId: _contractId,
        projectId: _projectId,
        name: name,
        isDefault: isDefault,
      );
      await _repository.addFolder(newFolder);
      await loadFolders();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateFolderName(String folderId, String newName) async {
    final currentList = state.valueOrNull ?? [];
    state = const AsyncValue.loading();
    try {
      final folder = currentList.firstWhere((f) => f.id == folderId);
      final updated = folder.copyWith(name: newName);
      await _repository.updateFolder(updated);
      await loadFolders();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteFolder(String folderId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteFolder(folderId);
      await loadFolders();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
