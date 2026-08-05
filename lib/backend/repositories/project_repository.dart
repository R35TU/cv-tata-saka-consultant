import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project_model.dart';
import 'base_repository.dart';

class ProjectRepository implements BaseRepository<ProjectModel> {
  final CollectionReference _collection = FirebaseFirestore.instance.collection('projects');

  @override
  Future<List<ProjectModel>> getAll() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map((doc) {
      return ProjectModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  @override
  Future<ProjectModel?> getById(dynamic id) async {
    final doc = await _collection.doc(id.toString()).get();
    if (!doc.exists || doc.data() == null) return null;
    return ProjectModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
  }

  @override
  Future<ProjectModel?> add(ProjectModel item) async {
    final docRef = await _collection.add(item.toJson());
    final doc = await docRef.get();
    if (doc.data() == null) return null;
    return ProjectModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
  }

  @override
  Future<bool> updateItem(dynamic id, ProjectModel item) async {
    try {
      final data = item.toJson();
      data.remove('id');
      await _collection.doc(id.toString()).update(data);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteItem(dynamic id) async {
    try {
      await _collection.doc(id.toString()).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<ProjectModel>> getByStatus(String status) async {
    final snapshot = await _collection.where('status', isEqualTo: status).get();
    return snapshot.docs.map((doc) {
      return ProjectModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }
}
