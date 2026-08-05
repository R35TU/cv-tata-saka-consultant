import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/database/hive_models.dart';
import '../models/project_model.dart';
import 'local_project_data_source.dart';

class ProjectFirebaseDataSourceImpl implements ProjectLocalDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  @override
  Future<void> init() async {}

  @override
  Future<List<String>> getProjectIdsForUser(String userId) async {
    final snapshot = await _firestore.collection('project_members')
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs.map((doc) => doc.data()['projectId'] as String).toList();
  }

  @override
  Future<List<ProjectModel>> getProjects({
    String? search,
    String? status,
    String? userRole,
    String? userId,
    bool? isArchived,
  }) async {
    final targetArchived = isArchived ?? false;

    // Role-based: kontraktor only sees projects they are a member of
    List<String>? allowedProjectIds;
    if (userRole == 'kontraktor' && userId != null) {
      allowedProjectIds = await getProjectIdsForUser(userId);
      if (allowedProjectIds.isEmpty) return [];
    } else if (userRole == 'eksternal') {
      allowedProjectIds = ['project-1'];
    }

    Query query = _firestore.collection('projects').where('isArchived', isEqualTo: targetArchived);

    if (status != null && status.toLowerCase() != 'semua') {
      query = query.where('status', isEqualTo: status);
    }

    final snapshot = await query.get();
    var list = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return ProjectModel.fromJson(data);
    }).toList();

    // Client side filtering for search and allowed projects
    if (search != null && search.isNotEmpty) {
      final s = search.toLowerCase();
      list = list.where((p) => p.name.toLowerCase().contains(s) || p.location.toLowerCase().contains(s)).toList();
    }

    if (allowedProjectIds != null) {
      list = list.where((p) => allowedProjectIds!.contains(p.id)).toList();
    }

    return list;
  }

  @override
  Future<List<ProjectMemberHive>> getProjectMembers(String projectId) async {
    final snapshot = await _firestore.collection('project_members')
        .where('projectId', isEqualTo: projectId)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return ProjectMemberHive()
        ..projectId = data['projectId']
        ..userId = data['userId']
        ..role = data['role'];
    }).toList();
  }

  @override
  Future<void> addProjectMember(String projectId, String userId, String role) async {
    final snapshot = await _firestore.collection('project_members')
        .where('projectId', isEqualTo: projectId)
        .where('userId', isEqualTo: userId)
        .get();
    if (snapshot.docs.isNotEmpty) return;

    await _firestore.collection('project_members').add({
      'projectId': projectId,
      'userId': userId,
      'role': role,
    });
  }

  @override
  Future<void> removeProjectMember(String projectId, String userId) async {
    final snapshot = await _firestore.collection('project_members')
        .where('projectId', isEqualTo: projectId)
        .where('userId', isEqualTo: userId)
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  @override
  Future<ProjectModel?> getProjectById(String id) async {
    final doc = await _firestore.collection('projects').doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    final data = doc.data()!;
    data['id'] = doc.id;
    return ProjectModel.fromJson(data);
  }

  @override
  Future<void> addProject(ProjectModel project) async {
    final data = project.toJson();
    data.remove('id'); // let firestore generate it or use it as doc id
    await _firestore.collection('projects').doc(project.id).set(data);
  }

  @override
  Future<void> updateProject(ProjectModel project) async {
    final data = project.toJson();
    data.remove('id');
    await _firestore.collection('projects').doc(project.id).update(data);
  }

  @override
  Future<void> deleteProject(String id) async {
    await _firestore.collection('projects').doc(id).delete();
  }

  @override
  Future<void> seedProjects() async {}
}
