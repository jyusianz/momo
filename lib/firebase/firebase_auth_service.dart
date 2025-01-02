import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Define your User class
class User1 {
  final String uid;
  final String email;
  final String userType;

  User1({
    required this.uid,
    required this.email,
    required this.userType,
  });
}

// Declare globalUID (Make sure this is in your main.dart or an appropriate global scope)
String? globalUID;

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register user and save data in Firestore
  Future<UserCredential> registerCredential(
      String email, String password, String userType) async {
    // Add userType parameter
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        // Determine the collection based on userType
        String collection = userType == 'Rider' ? 'Rider' : 'Consumer';

        await _firestore.collection(collection).doc(user.uid).set({
          'email': email,
          'uid': user.uid,
          'userType': userType, // Store userType in Firestore
          'createdAt': FieldValue.serverTimestamp(),
        });

        globalUID = user.uid;
      }

      return userCredential;
    } catch (e) {
      print("Error during registration: $e");
      rethrow;
    }
  }

  // Verify user credentials
  Future<UserCredential?> verifyCredential(
      String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Set the global UID after successful login
      if (userCredential.user != null) {
        globalUID = userCredential.user!.uid;
      }

      return userCredential;
    } catch (e) {
      print('Error logging in user: $e');
      return null;
    }
  }
}
