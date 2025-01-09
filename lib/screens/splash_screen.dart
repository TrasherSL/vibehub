import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:data_connection_checker_nulls/data_connection_checker_nulls.dart';
import 'login_screen.dart';
import 'user_dashboard.dart';
import 'admin_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late StreamSubscription<DataConnectionStatus> _connectionSubscription;

  @override
  void initState() {
    super.initState();
    _startMonitoringConnection();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUserLoginStatus();
    });
  }

  void _startMonitoringConnection() {
    _connectionSubscription = DataConnectionChecker().onStatusChange.listen(
          (DataConnectionStatus status) {
        if (status == DataConnectionStatus.disconnected) {
          _showNoConnectionSnackBar();
        }
      },
    );
  }

  Future<void> _checkUserLoginStatus() async {
    while (true) {
      final hasConnection = await DataConnectionChecker().hasConnection;

      if (hasConnection) {
        break;
      }
      _showNoConnectionSnackBar();
      await Future.delayed(const Duration(seconds: 3));
    }
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final userRole = userDoc.data()?['userRole'] ?? '';
      if (userRole == 'admin') {
        _navigateTo(const AdminDashboard());
      } else if (userRole == 'user') {
        _navigateTo(const UserDashboard());
      }
    } else {
      _navigateTo(const LoginScreen());
    }
  }


  void _showNoConnectionSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No internet connection. Please check your network.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _navigateTo(Widget destination) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  void dispose() {
    _connectionSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
