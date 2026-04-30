import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // GERAR CÓDIGO
  String generateFamilyCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rand = Random();

    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(rand.nextInt(chars.length))),
    );
  }

  // REGISTRO
  Future<void> register(
    String email,
    String password,
    String role,
    String name,
    String? familyCodeInput,
  ) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    User user = userCredential.user!;

    String familyCode;

    if (role == 'parent') {
      familyCode = generateFamilyCode();
    } else {
      if (familyCodeInput == null || familyCodeInput.isEmpty) {
        throw Exception("Informe o código da família");
      }
      familyCode = familyCodeInput;
    }

    await _db.collection('users').doc(user.uid).set({
      'email': email,
      'role': role,
      'name': name,
      'points': 0,
      'familyCode': familyCode,
    });
  }

  // LOGIN
  Future<User> login(String email, String password) async {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return userCredential.user!;
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }
}
