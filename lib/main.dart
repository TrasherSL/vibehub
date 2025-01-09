import 'dart:async';

import 'package:data_connection_checker_nulls/data_connection_checker_nulls.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:vibehub/firebase_options.dart';
import 'package:vibehub/screens/admin_dashboard.dart';
import 'package:vibehub/screens/admin_signup_screen.dart';
import 'package:vibehub/screens/login_screen.dart';
import 'package:vibehub/screens/manage_books_screen.dart';
import 'package:vibehub/screens/manage_movies_screen.dart';
import 'package:vibehub/screens/manage_music_screen.dart';
import 'package:vibehub/screens/manage_tv_shows_screen.dart';
import 'package:vibehub/screens/manage_users_screen.dart';
import 'package:vibehub/screens/splash_screen.dart';
import 'package:vibehub/screens/user_dashboard.dart';
import 'package:vibehub/screens/user_signup_screen.dart';
import 'package:vibehub/screens/view_books.dart';
import 'package:vibehub/screens/view_movies.dart';
import 'package:vibehub/screens/view_music.dart';
import 'package:vibehub/screens/view_tv_shows.dart';
import 'package:vibehub/services/connectivity_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp( options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "VibeHub",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurpleAccent),
        useMaterial3: true,
      ),
      home: ConnectionMonitor(child: const SplashScreen()),
      routes: {
        // '/': (context) => const SplashScreen(),
        // '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/userSignup': (context) => const UserSignUpScreen(),
        '/adminSignup': (context) => const AdminSignUpScreen(),
        '/userDashboard': (context) => UserDashboard(),
        '/adminDashboard': (context) => AdminDashboard(),
        '/manageMovies': (context) => ManageMoviesScreen(),
        '/manageBooks': (context) => ManageBooksScreen(),
        '/manageTVShows': (context) => ManageTVShowsScreen(),
        '/manageMusic': (context) => ManageMusicScreen(),
        '/manageUsers': (context) => ManageUsersScreen(),
        '/viewBooks': (context) => const ViewBooks(),
        '/viewMovies': (context) => const ViewMovies(),
        '/viewTVShows': (context) => const ViewTVShows(),
        '/viewMusic': (context) => const ViewMusic(),
      },
    );
  }
}
class ConnectionMonitor extends StatefulWidget {
  final Widget child;
  const ConnectionMonitor({required this.child, super.key});

  @override
  State<ConnectionMonitor> createState() => _ConnectionMonitorState();
}

class _ConnectionMonitorState extends State<ConnectionMonitor> {
  late StreamSubscription<DataConnectionStatus> _subscription;

  @override
  void initState() {
    super.initState();

    _subscription = connectivityService.connectionStatusStream.listen((status) {
      if (status == DataConnectionStatus.disconnected) {
        _showAlertDialog(
          title: "Alert",
          message: "Please check your internet connection.",
        );
      } else if (status == DataConnectionStatus.connected) {
        _showAlertDialog(
          title: "Alert",
          message: "Connected to the internet.",
        );
      }
    });
  }

  void _showAlertDialog({required String title, required String message}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
