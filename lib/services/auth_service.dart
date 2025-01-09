import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/vibehub_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign in with email and password
  // Future<UserCredential> signInWithEmailAndPassword(
  //     String email, String password) async {
  //   try {
  //     UserCredential result = await _auth.signInWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //     return result;
  //   } catch (e) {
  //     throw Exception(e.toString());
  //   }
  // }

  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return result;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        throw Exception('No user found for that email.'); // Or a custom exception
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        throw Exception('Wrong password provided for that user.'); // Or a custom exception
      } else if (e.code == 'invalid-email') {
        print('The email address is badly formatted.');
        throw Exception('The email address is badly formatted.');
      } else if (e.code == 'user-disabled') {
        print('The user account has been disabled.');
        throw Exception('The user account has been disabled.');
      } else if (e.code == 'too-many-requests') {
        print('Too many requests. Try again later.');
        throw Exception('Too many requests. Try again later.');
      } else if (e.code == 'operation-not-allowed') {
        print('Email/password sign in is not enabled.');
        throw Exception('Email/password sign in is not enabled.');
      }
      else {
        print('An error occurred during sign in: ${e.message}');
        throw Exception('An error occurred during sign in: ${e.message}'); // Generic exception
      }
    } catch (e) {
      // Catch other potential exceptions (e.g., network issues)
      print('An unexpected error occurred: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Create user with VibeHubUser model
  Future<void> createUser(VibeHubUser user) async {
    try {
      // Create user in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );

      // Store additional user details in Firestore
      await _firestore.collection('users').doc(result.user!.uid).set(user.toMap());
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current logged-in user as VibeHubUser
  Future<VibeHubUser?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      final docSnapshot =
      await _firestore.collection('users').doc(user.uid).get();
      return VibeHubUser.fromFirestore(docSnapshot);
    } else {
      return null;
    }
  }

  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }
}
