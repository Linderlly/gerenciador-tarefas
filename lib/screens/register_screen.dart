import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  String role = 'child';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Criar Conta")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Nome"),
            ),
            SizedBox(height: 10),

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

            DropdownButtonFormField<String>(
              value: role,
              items: [
                DropdownMenuItem(value: 'parent', child: Text("Pai")),
                DropdownMenuItem(value: 'child', child: Text("Filho")),
              ],
              onChanged: (value) {
                setState(() {
                  role = value!;
                });
              },
              decoration: InputDecoration(labelText: "Tipo de conta"),
            ),

            SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await authService.register(
                      emailController.text.trim(),
                      passwordController.text.trim(),
                      role,
                      nameController.text.trim(),
                    );

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
                child: Text("Cadastrar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
