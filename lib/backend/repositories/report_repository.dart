import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/report_model.dart';
import 'base_repository.dart';

class ReportRepository implements BaseRepository<ReportModel> {
  final CollectionReference _collection = FirebaseFirestore.instance.collection('reports');

  @override
  Future<List<ReportModel>> getAll() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map((doc) {
      return ReportModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  @override
  Future<ReportModel?> getById(dynamic id) async {
    final doc = await _collection.doc(id.toString()).get();
    if (!doc.exists || doc.data() == null) return null;
    return ReportModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
  }

  Future<List<ReportModel>> getByProjectId(String projectId) async {
    final snapshot = await _collection.where('proyek_id', isEqualTo: projectId).get();
    return snapshot.docs.map((doc) {
      return ReportModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  @override
  Future<ReportModel?> add(ReportModel item) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final itemData = item.toJson();
    if (currentUserId != null) {
      itemData['pembuat_id'] = currentUserId;
    }
    final docRef = await _collection.add(itemData);
    final doc = await docRef.get();
    if (doc.data() == null) return null;
    return ReportModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
  }

  @override
  Future<bool> updateItem(dynamic id, ReportModel item) async {
    try {
      final docRef = _collection.doc(id.toString());
      final doc = await docRef.get();
      if (!doc.exists || doc.data() == null) return false;
      
      // Mitigasi IDOR: Dapatkan ID User saat ini
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) return false;

      final docData = doc.data() as Map<String, dynamic>;
      // Pastikan pembuat laporan sama dengan user yang sedang login
      if (docData['pembuat_id'] != currentUserId) return false;

      final data = item.toJson();
      data.remove('id');
      await docRef.update(data);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteItem(dynamic id) async {
    try {
      final docRef = _collection.doc(id.toString());
      final doc = await docRef.get();
      if (!doc.exists || doc.data() == null) return false;

      // Mitigasi IDOR: Dapatkan ID User saat ini
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) return false;

      final docData = doc.data() as Map<String, dynamic>;
      // Pastikan pembuat laporan sama dengan user yang sedang login
      if (docData['pembuat_id'] != currentUserId) return false;

      await docRef.delete();
      return true;
    } catch (e) {
      return false;
    }
  }
}