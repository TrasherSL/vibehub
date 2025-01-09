import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/book_service.dart';

class ManageBooksScreen extends StatefulWidget {
  const ManageBooksScreen({Key? key}) : super(key: key);

  @override
  State<ManageBooksScreen> createState() => _ManageBooksScreenState();
}

class _ManageBooksScreenState extends State<ManageBooksScreen> {
  final BookService _bookService = BookService();
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _author = '';
  String _description = '';
  int _publishedYear = 0;
  double _grade = 0.0;

  Future<void> _showBookDialog([Book? book]) async {
    if (book != null) {
      _title = book.title;
      _author = book.author;
      _description = book.description;
      _publishedYear = book.publishedYear;
      _grade = book.grade;
    } else {
      _title = '';
      _author = '';
      _description = '';
      _publishedYear = 0;
      _grade = 0.0;
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(book == null ? 'Add Book' : 'Edit Book'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  initialValue: _title,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter a title' : null,
                  onSaved: (value) => _title = value!,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  initialValue: _author,
                  decoration: const InputDecoration(labelText: 'Author'),
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter an author' : null,
                  onSaved: (value) => _author = value!,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  initialValue: _description,
                  decoration: const InputDecoration(labelText: 'Description'),
                  onSaved: (value) => _description = value!,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  initialValue: _publishedYear.toString(),
                  decoration: const InputDecoration(labelText: 'Published Year'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter a year' : null,
                  onSaved: (value) =>
                  _publishedYear = int.parse(value!),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  initialValue: _grade.toString(),
                  decoration: const InputDecoration(labelText: 'Grade'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter a grade' : null,
                  onSaved: (value) =>
                  _grade = double.parse(value!),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                if (book == null) {
                  await _bookService.addBook(Book(
                    id: '',
                    title: _title,
                    author: _author,
                    description: _description,
                    publishedYear: _publishedYear,
                    grade: _grade,
                  ));
                } else {
                  await _bookService.updateBook(book.id, {
                    'title': _title,
                    'author': _author,
                    'description': _description,
                    'published_year': _publishedYear,
                    'grade': _grade,
                  });
                }
                Navigator.pop(context);
              }
            },
            child: Text(book == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBook(String id) async {
    await _bookService.deleteBook(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Books'),
      ),
      body: StreamBuilder<List<Book>>(
        stream: _bookService.getBooks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No books available'));
          }

          final books = snapshot.data!;
          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: Icon(Icons.book_online_outlined),
                  title: Text(book.title),
                  subtitle: Text('${book.author} - ${book.publishedYear}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showBookDialog(book),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteBook(book.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBookDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
