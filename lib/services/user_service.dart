import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/vibehub_user.dart';

class UserService {
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

  Future<void> addUser(VibeHubUser user) async {
    await usersCollection.add(user.toMap());
  }

  Future<void> updateUser(String id, Map<String, dynamic> updates) async {
    await usersCollection.doc(id).update(updates);
  }

  Future<void> deleteUser(String id) async {
    await usersCollection.doc(id).delete();
  }

  Stream<List<VibeHubUser>> getUsers() {
    return usersCollection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc1) => VibeHubUser.fromFirestore(doc1 as DocumentSnapshot<Map<String, dynamic>>)).toList());
  }
}
