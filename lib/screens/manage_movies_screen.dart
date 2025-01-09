import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';
import 'dart:io';

class ManageMoviesScreen extends StatefulWidget {
  const ManageMoviesScreen({Key? key}) : super(key: key);

  @override
  State<ManageMoviesScreen> createState() => _ManageMoviesScreenState();
}

class _ManageMoviesScreenState extends State<ManageMoviesScreen> {
  final MovieService _movieService = MovieService();
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';
  int _year = 0;
  double _ratings = 0.0;

  Future<void> _showMovieDialog([Movie? movie]) async {
    final picker = ImagePicker();
    if (movie != null) {
      _name = movie.name;
      _description = movie.description;
      _year = movie.year;
      _ratings = movie.ratings;
    } else {
      _name = '';
      _description = '';
      _year = 0;
      _ratings = 0.0;
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(movie == null ? 'Add Movie' : 'Edit Movie'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  initialValue: _name,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
                  onSaved: (value) => _name = value!,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  initialValue: _description,
                  decoration: const InputDecoration(labelText: 'Description'),
                  onSaved: (value) => _description = value!,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  initialValue: _year.toString(),
                  decoration: const InputDecoration(labelText: 'Year'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Please enter a year' : null,
                  onSaved: (value) => _year = int.parse(value!),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  initialValue: _ratings.toString(),
                  decoration: const InputDecoration(labelText: 'Ratings'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Please enter a rating' : null,
                  onSaved: (value) => _ratings = double.parse(value!),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      final storageRef = FirebaseStorage.instance
                          .ref()
                          .child('movie_posters/${DateTime.now().millisecondsSinceEpoch}');
                      await storageRef.putFile(File(pickedFile.path));
                      setState(() {});
                    }
                  },
                  child: const Text('Upload Poster'),
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
                if (movie == null) {
                  await _movieService.addMovie(Movie(
                    id: '',
                    name: _name,
                    description: _description,
                    year: _year,
                    ratings: _ratings,
                  ));
                } else {
                  await _movieService.updateMovie(movie.id, {
                    'name': _name,
                    'description': _description,
                    'year': _year,
                    'ratings': _ratings,
                  });
                }
                Navigator.pop(context);
              }
            },
            child: Text(movie == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMovie(String id) async {
    await _movieService.deleteMovie(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Movies'),
      ),
      body: StreamBuilder<List<Movie>>(
        stream: _movieService.getMovies(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No movies available'));
          }

          final movies = snapshot.data!;
          return ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: const Icon(Icons.movie, size: 50),
                  title: Text(movie.name),
                  subtitle: Text('${movie.year} - Rating: ${movie.ratings}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showMovieDialog(movie),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteMovie(movie.id),
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
        onPressed: () => _showMovieDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
