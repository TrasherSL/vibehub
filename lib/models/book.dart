import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final int publishedYear;
  final double grade;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.publishedYear,
    required this.grade,
  });

  factory Book.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return Book(
      id: snapshot.id,
      title: data?['title'] ?? '',
      author: data?['author'] ?? '',
      description: data?['description'] ?? '',
      publishedYear: data?['published_year'] ?? 0,
      grade: (data?['grade'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'description': description,
      'published_year': publishedYear,
      'grade': grade,
    };
  }
}
