import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:math';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class FirebaseService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future<void> saveUserFace(
      String userId, String imageUrl, List<double> mobilefacenetEmbedding, List<double> facenetEmbedding) async {
    await firestore.collection('Users').doc(userId).set({
      'imageUrl': imageUrl,
      'mobilefacenetEmbedding': mobilefacenetEmbedding,
      'facenetEmbedding': facenetEmbedding,
    });
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("Users")
          .doc(userId)
          .get();

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      } else {
        print("User document does not exist.");
        return null;
      }
    } catch (e) {
      print("Error fetching Firebase data: $e");
      return null;
    }
  }

  Future<List<String>> getPersonIds(String type, List<String> classIds) async {
    List<String> userIds = [];
    for (var classId in classIds) {
      DocumentSnapshot classDoc = await firestore.collection('Classes').doc(classId).get();
      if (classDoc.exists) {
        var data = classDoc.data() as Map<String, dynamic>;
        if (type == "student_ids") {
          userIds.addAll(List<String>.from(data['student_ids'] ?? []));
        } else if (type == "servant_ids") {
          userIds.addAll(List<String>.from(data['servant_ids'] ?? []));
        }
      }
    }
    return userIds;
  }

  Future<List<String>> getCurrentUserClasses() async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      QuerySnapshot userDocs = await firestore.collection('Users').where('uid', isEqualTo: user.uid).get();

      if (userDocs.docs.isNotEmpty) {
        DocumentSnapshot userDoc = userDocs.docs.first;
        String userDocId = userDoc.id;
        String userRole = userDoc['role'];

        List<String> userClassIds = [];

        if (userRole == "student") {
          QuerySnapshot classDocs = await firestore.collection('Classes')
              .where('student_ids', arrayContains: userDocId)
              .get();

          if (classDocs.docs.isNotEmpty) {
            userClassIds.add(classDocs.docs.first.id);
          }

        }
        else if (userRole == "servant") {
          QuerySnapshot classDocs = await firestore.collection('Classes')
              .where('servant_ids', arrayContains: userDocId)
              .get();

          userClassIds = classDocs.docs.map((doc) => doc.id).toList();
        }
        return userClassIds;
      }
    }
    return [];
  }

  Future<String> getCurrentUserRole() async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      QuerySnapshot userDocs = await firestore.collection('Users').where('uid', isEqualTo: user.uid).get();

      if (userDocs.docs.isNotEmpty) {
        DocumentSnapshot userDoc = userDocs.docs.first;
        String userRole = userDoc['role'];

        return userRole;
      }
    }
    return "";
  }

  Future<String> getCurrentUserID() async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      QuerySnapshot userDocs = await firestore.collection('Users').where('uid', isEqualTo: user.uid).get();

      if (userDocs.docs.isNotEmpty) {
        DocumentSnapshot userDoc = userDocs.docs.first;
        String userDocId = userDoc.id;
        return userDocId;
      } else {
        print("No user found with uid: ${user.uid}");
      }
    }
    return "";
  }

  Future<void> registerUser(String docId, String email, String name) async {
    try {
      // Generate a random password
      String password = _generateRandomPassword();

      // Create Firebase Auth user
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid; // Firebase Auth UID

      // Update the existing Firestore document with UID
      await FirebaseFirestore.instance.collection('Users').doc(docId).update({
        'uid': uid, // Store Firebase Auth UID
      });

      // Send email with credentials
      await _sendEmail(email, name, password);

      print("User registered and credentials sent to $email");
    } catch (e) {
      print("Error: $e");
    }
  }

  String _generateRandomPassword({int length = 8}) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789@#\$%&*';
    Random random = Random();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }

  Future<void> _sendEmail(String recipientEmail, String name, String password) async {
    String username = dotenv.env['EMAIL_USERNAME']!;
    String passwordEmail = dotenv.env['EMAIL_PASSWORD']!;

    final smtpServer = gmail(username, passwordEmail);
    final message = Message()
      ..from = Address(username, 'Admin')
      ..recipients.add(recipientEmail)
      ..subject = 'Your Account Credentials'
      ..text = 'Hello $name,\n\nYour account has been created.\n\nEmail: $recipientEmail\nPassword: $password\n\nPlease log in and change your password.\n\nBest regards,';

    try {
      await send(message, smtpServer);
      print("Email sent successfully to $recipientEmail");
    } catch (e) {
      print("Failed to send email: $e");
    }
  }

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
