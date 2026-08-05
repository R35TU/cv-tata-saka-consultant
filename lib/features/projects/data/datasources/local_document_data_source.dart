import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/database/hive_database_service.dart';
import '../../../../core/database/hive_models.dart';
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
  @override
  Future<void> init() async {
    await HiveDatabaseService.initDb();
  }

  @override
  Future<List<DocumentModel>> getDocuments(String projectId) async {
    final box = Hive.box<DocumentHive>('documents');
    final list = box.values.where((d) => d.projectId == projectId).toList();
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
    final box = Hive.box<DocumentHive>('documents');
    final hiveDoc = DocumentHive()
      ..documentId = document.id
      ..projectId = document.projectId
      ..folderName = document.folderName
      ..name = document.name
      ..fileUrl = document.fileUrl
      ..fileSize = document.fileSize
      ..uploadedBy = document.uploadedBy
      ..uploadedAt = document.uploadedAt
      ..version = document.version
      ..versions = document.versions.map((v) => DocumentVersionHive()
        ..versionId = v.id
        ..name = v.name
        ..fileUrl = v.fileUrl
        ..fileSize = v.fileSize
        ..uploadedBy = v.uploadedBy
        ..uploadedAt = v.uploadedAt
        ..version = v.version
      ).toList();
    await box.put(document.id, hiveDoc);
  }

  @override
  Future<void> updateDocument(DocumentModel document) async {
    await addDocument(document);
  }

  @override
  Future<void> deleteDocument(String id) async {
    final box = Hive.box<DocumentHive>('documents');
    await box.delete(id);
  }

  @override
  Future<void> seedDocuments() async {}
}
