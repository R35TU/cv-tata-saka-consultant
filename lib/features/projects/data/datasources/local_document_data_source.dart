import 'package:isar/isar.dart';
import '../../../../core/database/isar_database_service.dart';
import '../../../../core/database/isar_models.dart';
import '../models/document_model.dart';

abstract class DocumentLocalDataSource {
  Future<void> init();
  Future<List<DocumentModel>> getDocuments(String projectId);
  Future<void> addDocument(DocumentModel document);
  Future<void> updateDocument(DocumentModel document);
  Future<void> deleteDocument(String id);
  Future<void> seedDocuments();
}

class DocumentLocalDataSourceImpl implements DocumentLocalDataSource {
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
  Future<List<DocumentModel>> getDocuments(String projectId) async {
    final database = await db;
    final list = await database.documentIsars.filter().projectIdEqualTo(projectId).findAll();
    return list.map((raw) => DocumentModel(
      id: raw.documentId,
      projectId: raw.projectId,
      folderName: raw.folderName,
      name: raw.name,
      fileUrl: raw.fileUrl,
      fileSize: raw.fileSize,
      uploadedBy: raw.uploadedBy,
      uploadedAt: raw.uploadedAt,
      version: raw.version,
      versions: raw.versions.map((v) => DocumentVersion(
        id: v.versionId,
        name: v.name,
        fileUrl: v.fileUrl,
        fileSize: v.fileSize,
        uploadedBy: v.uploadedBy,
        uploadedAt: v.uploadedAt,
        version: v.version,
      )).toList(),
    )).toList();
  }

  @override
  Future<void> addDocument(DocumentModel document) async {
    final database = await db;
    await database.writeTxn(() async {
      final isarDoc = DocumentIsar()
        ..documentId = document.id
        ..projectId = document.projectId
        ..folderName = document.folderName
        ..name = document.name
        ..fileUrl = document.fileUrl
        ..fileSize = document.fileSize
        ..uploadedBy = document.uploadedBy
        ..uploadedAt = document.uploadedAt
        ..version = document.version
        ..versions = document.versions.map((v) => DocumentVersionIsar()
          ..versionId = v.id
          ..name = v.name
          ..fileUrl = v.fileUrl
          ..fileSize = v.fileSize
          ..uploadedBy = v.uploadedBy
          ..uploadedAt = v.uploadedAt
          ..version = v.version
        ).toList();
      await database.documentIsars.put(isarDoc);
    });
  }

  @override
  Future<void> updateDocument(DocumentModel document) async {
    final database = await db;
    final existing = await database.documentIsars.filter().documentIdEqualTo(document.id).findFirst();
    await database.writeTxn(() async {
      final isarDoc = (existing ?? DocumentIsar())
        ..documentId = document.id
        ..projectId = document.projectId
        ..folderName = document.folderName
        ..name = document.name
        ..fileUrl = document.fileUrl
        ..fileSize = document.fileSize
        ..uploadedBy = document.uploadedBy
        ..uploadedAt = document.uploadedAt
        ..version = document.version
        ..versions = document.versions.map((v) => DocumentVersionIsar()
          ..versionId = v.id
          ..name = v.name
          ..fileUrl = v.fileUrl
          ..fileSize = v.fileSize
          ..uploadedBy = v.uploadedBy
          ..uploadedAt = v.uploadedAt
          ..version = v.version
        ).toList();
      await database.documentIsars.put(isarDoc);
    });
  }

  @override
  Future<void> deleteDocument(String id) async {
    final database = await db;
    final existing = await database.documentIsars.filter().documentIdEqualTo(id).findFirst();
    if (existing != null) {
      await database.writeTxn(() async {
        await database.documentIsars.delete(existing.id);
      });
    }
  }

  @override
  Future<void> seedDocuments() async {
    // Already handled in IsarDatabaseService
  }
}
