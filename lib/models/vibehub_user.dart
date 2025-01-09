  import 'package:cloud_firestore/cloud_firestore.dart';

  class VibeHubUser {
    final String uid;
    final String email;
    final String password;
    final String userRole;
    late final String name;

    VibeHubUser({
      required this.uid,
      required this.email,
      required this.password,
      required this.userRole,
      required this.name,
    });

    factory VibeHubUser.fromFirestore(
        DocumentSnapshot<Map<String, dynamic>> snapshot) {
      final data = snapshot.data();
      return VibeHubUser(
        uid: snapshot.id,
        email: data?['email'] ?? '',
        password: data?['password'] ?? '',
        userRole: data?['userRole'] ?? '',
        name: data?['name'] ?? '',
      );
    }

    Map<String, dynamic> toMap() {
      return {
        'email': email,
        'password': password,
        'userRole': userRole,
        'name': name,
      };
    }

    VibeHubUser copyWith({
      String? uid,
      String? email,
      String? password,
      String? userRole,
      String? name,
    }) {
      return VibeHubUser(
        uid: uid ?? this.uid,
        email: email ?? this.email,
        password: password ?? this.password,
        userRole: userRole ?? this.userRole,
        name: name ?? this.name,
      );
    }
  }