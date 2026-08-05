import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'base_repository.dart';

class UserRepository implements BaseRepository<UserModel> {
  final CollectionReference _collection = FirebaseFirestore.instance.collection('users');

  @override
  Future<List<UserModel>> getAll() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return UserModel.fromJson(data, doc.id, '');
    }).toList();
  }

  @override
  Future<UserModel?> getById(dynamic id) async {
    final doc = await _collection.doc(id.toString()).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromJson(doc.data() as Map<String, dynamic>, doc.id, '');
  }

  @override
  Future<UserModel?> add(UserModel item) async {
    await _collection.doc(item.id).set(item.toJson());
    return item;
  }

  @override
  Future<bool> updateItem(dynamic id, UserModel item) async {
    try {
      await _collection.doc(id.toString()).update(item.toJson());
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
}
