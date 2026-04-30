import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService authService = AuthService();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(Icons.task_alt, size: 80, color: Colors.blue),
                SizedBox(height: 20),

                Text(
                  "Bem-vindo",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 20),

                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: "Email"),
                ),

                SizedBox(height: 10),

                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: "Senha"),
                  obscureText: true,
                ),

                SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        var user = await authService.login(
                          emailController.text.trim(),
                          passwordController.text.trim(),
                        );

                        var userDoc = await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .get();

                        String role = userDoc['role'];

                        if (role == 'parent') {
                          Navigator.pushReplacementNamed(context, '/parent');
                        } else {
                          Navigator.pushReplacementNamed(context, '/child');
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text("Erro: $e")));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text("Entrar"),
                  ),
                ),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterScreen()),
                    );
                  },
                  child: Text("Criar conta"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
