import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/calendar_screen.dart';

class AppDrawer extends StatelessWidget {
  final String name;
  final bool isDark;
  final Function(bool) onThemeChanged;
  final bool isParent;

  const AppDrawer({
    super.key,
    required this.name,
    required this.isDark,
    required this.onThemeChanged,
    required this.isParent,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.purpleAccent],
              ),
            ),
            accountName: Text(name),
            accountEmail: Text("Bem-vindo 👋"),
            currentAccountPicture: CircleAvatar(
              child: Icon(Icons.person, size: 40),
            ),
          ),

          // 🌙 MODO ESCURO
          SwitchListTile(
            title: Text("Modo escuro"),
            value: isDark,
            onChanged: onThemeChanged,
            secondary: Icon(Icons.dark_mode),
          ),

          Divider(),

          // CALENDÁRIO
          ListTile(
            leading: Icon(Icons.calendar_month),
            title: Text("Calendário"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CalendarScreen(isParent: isParent),
                ),
              );
            },
          ),

          // SOBRE
          ListTile(
            leading: Icon(Icons.info),
            title: Text("Sobre o app"),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "Gerenciador de Tarefas",
                applicationVersion: "1.0.0",
                children: [
                  Text("Sistema de tarefas com recompensas."),
                ],
              );
            },
          ),

          Spacer(),

          // LOGOUT
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text("Sair"),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
