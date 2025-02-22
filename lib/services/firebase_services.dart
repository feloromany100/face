import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class FirebaseService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> saveUserFace(
      String userId, String imageUrl, List<double> mobilefacenetEmbedding, List<double> facenetEmbedding) async {
    await firestore.collection('users').doc(userId).set({
      'imageUrl': imageUrl,
      'mobilefacenetEmbedding': mobilefacenetEmbedding,
      'facenetEmbedding': facenetEmbedding,
    });
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    DocumentSnapshot snapshot = await firestore.collection('users').doc(userId).get();
    if (snapshot.exists) {
      return snapshot.data() as Map<String, dynamic>;
    }
    return null;
  }
}

class AuthService {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  // Login method
  Future<User?> login(String email, String password) async {
    UserCredential userCredential = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  // Logout method
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  // Reset password method
  Future<void> resetPassword(String email) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }
}
