import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/music.dart';

class MusicService {
  final CollectionReference musicCollection =
  FirebaseFirestore.instance.collection('music');

  Future<void> addMusic(Music music) async {
    await musicCollection.add(music.toMap());
  }

  Future<void> updateMusic(String id, Map<String, dynamic> updates) async {
    await musicCollection.doc(id).update(updates);
  }

  Future<void> deleteMusic(String id) async {
    await musicCollection.doc(id).delete();
  }

  Stream<List<Music>> getMusic() {
    return musicCollection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Music.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>)).toList());
  }
}