import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<User?> registerUser(String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      User? user = result.user;

      await user?.updateDisplayName(name);

      // CRITICAL: This allows other users to find them by email
      await _db.collection('users').doc(user?.uid).set({
        'uid': user?.uid,
        'name': name,
        'email': email
            .trim()
            .toLowerCase(), // Store lowercase for easier searching
        'createdAt': FieldValue.serverTimestamp(),
      });

      return user;
    } catch (e) {
      print("Register Error: $e");
      return null;
    }
  }

  Future<User?> loginUser(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return result.user;
    } catch (e) {
      print("Login Error: $e");
      return null;
    }
  }

  Future<void> signOut() async => await _auth.signOut();
}
