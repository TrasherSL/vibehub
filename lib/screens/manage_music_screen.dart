import 'package:flutter/material.dart';
import '../models/music.dart';
import '../services/music_service.dart';

class ManageMusicScreen extends StatefulWidget {
  const ManageMusicScreen({Key? key}) : super(key: key);

  @override
  _ManageMusicScreenState createState() => _ManageMusicScreenState();
}

class _ManageMusicScreenState extends State<ManageMusicScreen> {
  final MusicService _musicService = MusicService();
  final _formKey = GlobalKey<FormState>();

  String _title = '';
  String _artist = '';
  String _album = '';
  String _genre = '';
  int _releaseYear = 0;

  Future<void> _showMusicDialog([Music? music]) async {
    if (music != null) {
      _title = music.title;
      _artist = music.artist;
      _album = music.album;
      _genre = music.genre;
      _releaseYear = music.releaseYear;
    } else {
      _title = '';
      _artist = '';
      _album = '';
      _genre = '';
      _releaseYear = 0;
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(music == null ? 'Add Music' : 'Edit Music'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _buildTextField('Title', _title, (value) => _title = value!),
                _buildTextField('Artist', _artist, (value) => _artist = value!),
                _buildTextField('Album', _album, (value) => _album = value!),
                _buildTextField('Genre', _genre, (value) => _genre = value!),
                _buildTextField('Release Year', _releaseYear.toString(), (value) => _releaseYear = int.parse(value!),
                    keyboardType: TextInputType.number),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                if (music == null) {
                  await _musicService.addMusic(Music(
                    id: '',
                    title: _title,
                    artist: _artist,
                    album: _album,
                    genre: _genre,
                    releaseYear: _releaseYear,
                  ));
                } else {
                  await _musicService.updateMusic(music.id, {
                    'title': _title,
                    'artist': _artist,
                    'album': _album,
                    'genre': _genre,
                    'releaseYear': _releaseYear,
                  });
                }
                Navigator.pop(context);
              }
            },
            child: Text(music == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  TextFormField _buildTextField(String label, String initialValue, Function(String?) onSaved,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(labelText: label),
      keyboardType: keyboardType,
      validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
      onSaved: onSaved,
    );
  }

  Future<void> _deleteMusic(String id) async {
    await _musicService.deleteMusic(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Music')),
      body: StreamBuilder<List<Music>>(
        stream: _musicService.getMusic(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No music available'));
          }

          final musicList = snapshot.data!;
          return ListView.builder(
            itemCount: musicList.length,
            itemBuilder: (context, index) {
              final music = musicList[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: const Icon(Icons.music_note, size: 50, color: Colors.deepPurple),
                  title: Text(music.title),
                  subtitle: Text('${music.artist} - ${music.releaseYear}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showMusicDialog(music)),
                      IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteMusic(music.id)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMusicDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
