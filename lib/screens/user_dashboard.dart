import 'package:flutter/material.dart';
import 'package:vibehub/services/auth_service.dart';

class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
              onPressed: () {
                AuthService().signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
              icon: Icon(Icons.logout_outlined, color: Colors.white,))
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildDashboardTile(context, Icons.movie, 'Movies', '/viewMovies'),
          _buildDashboardTile(context, Icons.book, 'Books', '/viewBooks'),
          _buildDashboardTile(context, Icons.tv, 'TV Shows', '/viewTVShows'),
          _buildDashboardTile(context, Icons.music_note, 'Music', '/viewMusic'),
        ],
      ),
    );
  }

  Widget _buildDashboardTile(
      BuildContext context, IconData icon, String label, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.deepPurple),
            const SizedBox(height: 10),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
