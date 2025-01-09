import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie.dart';

class MovieService {
  final CollectionReference moviesCollection =
  FirebaseFirestore.instance.collection('movies');

  Future<void> addMovie(Movie movie) async {
    await moviesCollection.add(movie.toMap());
  }

  Future<void> updateMovie(String id, Map<String, dynamic> updates) async {
    await moviesCollection.doc(id).update(updates);
  }

  Future<void> deleteMovie(String id) async {
    await moviesCollection.doc(id).delete();
  }

  Stream<List<Movie>> getMovies() {
    return moviesCollection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Movie.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>)).toList());
  }
}
