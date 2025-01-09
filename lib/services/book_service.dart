import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';

class BookService {
  final CollectionReference booksCollection = FirebaseFirestore.instance.collection('books');

  Future<void> addBook(Book book) async {
    await booksCollection.add(book.toMap());
  }

  Future<void> updateBook(String id, Map<String, dynamic> updates) async {
    await booksCollection.doc(id).update(updates);
  }

  Future<void> deleteBook(String id) async {
    await booksCollection.doc(id).delete();
  }

  Stream<List<Book>> getBooks() {
    return booksCollection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc1) => Book.fromFirestore(doc1 as DocumentSnapshot<Map<String, dynamic>>)).toList());
  }
}
