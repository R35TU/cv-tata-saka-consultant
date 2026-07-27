import '../datasources/local_document_data_source.dart';
import '../models/document_model.dart';

abstract class DocumentRepository {
  Future<void> init();
  Future<List<DocumentModel>> getDocuments(String projectId);
  Future<void> addDocument(DocumentModel document);
  Future<void> updateDocument(DocumentModel document);
  Future<void> deleteDocument(String id);
}

class DocumentRepositoryImpl implements DocumentRepository {
  final DocumentLocalDataSource localDataSource;

  DocumentRepositoryImpl(this.localDataSource);

  @override
  Future<void> init() => localDataSource.init();

  @override
  Future<List<DocumentModel>> getDocuments(String projectId) =>
      localDataSource.getDocuments(projectId);

  @override
  Future<void> addDocument(DocumentModel document) =>
      localDataSource.addDocument(document);

  @override
  Future<void> updateDocument(DocumentModel document) =>
      localDataSource.updateDocument(document);

  @override
  Future<void> deleteDocument(String id) =>
      localDataSource.deleteDocument(id);
}
