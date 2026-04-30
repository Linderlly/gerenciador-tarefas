import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  //REGISTRAR USUÁRIO
  Future<void> register(
    String email,
    String password,
    String role,
    String name,
  ) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    User user = userCredential.user!;

    //CRIA DOCUMENTO NO FIRESTORE
    await _db.collection('users').doc(user.uid).set({
      'email': email,
      'role': role,
      'points': 0,
      'name': name,
    });
  }

  //LOGIN
  Future<User> login(String email, String password) async {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return userCredential.user!;
  }
}
