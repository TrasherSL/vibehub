import 'package:cloud_firestore/cloud_firestore.dart';

class TVShow {
  final String id;
  final String name;
  final String overview;
  final String type;
  final double popularity;

  TVShow({
    required this.id,
    required this.name,
    required this.overview,
    required this.type,
    required this.popularity,
  });

  factory TVShow.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return TVShow(
      id: snapshot.id,
      name: data?['name'] ?? '',
      overview: data?['overview'] ?? '',
      type: data?['type'] ?? '',
      popularity: (data?['popularity'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'overview': overview,
      'type': type,
      'popularity': popularity,
    };
  }
}
