import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tarefas dos Filhos")),
      body: Center(
        child: Text("Bem-vindo ao aplicativo!", style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
