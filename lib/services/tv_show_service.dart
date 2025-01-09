import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tv_show.dart';

class TVShowService {
  final CollectionReference _tvShowCollection =
  FirebaseFirestore.instance.collection('tvShows');

  Stream<List<TVShow>> getTVShows() {
    return _tvShowCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => TVShow.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
    });
  }

  Future<void> addTVShow(TVShow tvShow) async {
    await _tvShowCollection.add(tvShow.toMap());
  }

  Future<void> updateTVShow(String id, Map<String, dynamic> data) async {
    await _tvShowCollection.doc(id).update(data);
  }

  Future<void> deleteTVShow(String id) async {
    await _tvShowCollection.doc(id).delete();
  }
}
