import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/tv_show.dart';
import '../services/tv_show_service.dart';
import '../services/storage_service.dart';

class ManageTVShowsScreen extends StatefulWidget {
  const ManageTVShowsScreen({Key? key}) : super(key: key);

  @override
  State<ManageTVShowsScreen> createState() => _ManageTVShowsScreenState();
}

class _ManageTVShowsScreenState extends State<ManageTVShowsScreen> {
  final TVShowService _tvShowService = TVShowService();
  final StorageService _storageService = StorageService();
  final _formKey = GlobalKey<FormState>();

  String _name = '';
  String _overview = '';
  String _type = '';
  double _popularity = 0.0;
  File? _selectedImage;

  Future<void> _pickImage() async {
    final pickedImage =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _showTVShowDialog([TVShow? tvShow]) async {
    double uploadProgress = 0.0;

    if (tvShow != null) {
      _name = tvShow.name;
      _overview = tvShow.overview;
      _type = tvShow.type;
      _popularity = tvShow.popularity;
    } else {
      _name = '';
      _overview = '';
      _type = '';
      _popularity = 0.0;
      _selectedImage = null;
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(tvShow == null ? 'Add TV Show' : 'Edit TV Show'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    initialValue: _name,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) =>
                    value!.isEmpty ? 'Please enter a name' : null,
                    onSaved: (value) => _name = value!,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: _overview,
                    decoration: const InputDecoration(labelText: 'Overview'),
                    onSaved: (value) => _overview = value!,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: _type,
                    decoration: const InputDecoration(labelText: 'Type'),
                    onSaved: (value) => _type = value!,
                  ),
                  const SizedBox(height: 10),
                  _selectedImage == null
                      ? TextButton(
                    onPressed: _pickImage,
                    child: const Text('Pick Backdrop Image'),
                  )
                      : Column(
                    children: [
                      Image.file(
                        _selectedImage!,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                      LinearProgressIndicator(value: uploadProgress / 100),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: _popularity.toString(),
                    decoration: const InputDecoration(labelText: 'Popularity'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty
                        ? 'Please enter popularity'
                        : null,
                    onSaved: (value) =>
                    _popularity = double.parse(value!),
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
                  if (tvShow == null) {
                    await _tvShowService.addTVShow(TVShow(
                      id: '',
                      name: _name,
                      overview: _overview,
                      type: _type,
                      popularity: _popularity,
                    ));
                  } else {
                    await _tvShowService.updateTVShow(tvShow.id, {
                      'name': _name,
                      'overview': _overview,
                      'type': _type,
                      'popularity': _popularity,
                    });
                  }

                  Navigator.pop(context);
                }
              },
              child: Text(tvShow == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteTVShow(String id) async {
    await _tvShowService.deleteTVShow(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage TV Shows'),
      ),
      body: StreamBuilder<List<TVShow>>(
        stream: _tvShowService.getTVShows(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No TV shows available'));
          }

          final tvShows = snapshot.data!;
          return ListView.builder(
            itemCount: tvShows.length,
            itemBuilder: (context, index) {
              final tvShow = tvShows[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: const Icon(Icons.tv, size: 50, color: Colors.grey),
                  title: Text(tvShow.name),
                  subtitle: Text(
                      '${tvShow.type} - Popularity: ${tvShow.popularity.toStringAsFixed(1)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showTVShowDialog(tvShow),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteTVShow(tvShow.id),
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
        onPressed: () => _showTVShowDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
