import 'package:flutter/material.dart';
import '../models/music.dart';
import '../services/music_service.dart';

class ViewMusic extends StatelessWidget {
  const ViewMusic({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Music')),
      body: StreamBuilder<List<Music>>(
        stream: MusicService().getMusic(),
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
              return ListTile(
                leading: const Icon(Icons.music_note, size: 50, color: Colors.deepPurple),
                title: Text(music.title),
                subtitle: Text('${music.artist} - ${music.genre}'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(music.title),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.music_note),
                            const SizedBox(height: 10),
                            Text('Artist: ${music.artist}'),
                            const SizedBox(height: 5),
                            Text('Genre: ${music.genre}'),
                            const SizedBox(height: 5),
                            Text('Album: ${music.album}'),
                            const SizedBox(height: 5),
                            Text('Release Year: ${music.releaseYear}'),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
