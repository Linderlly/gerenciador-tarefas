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
    final theme = Theme.of(context);

    // CORES VINDAS DO THEME.DART
    final primary = theme.colorScheme.primary;
    final surface = theme.colorScheme.surface;
    final textColor = theme.textTheme.bodyLarge?.color;

    return Drawer(
      backgroundColor: surface,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            // REMOVIDO O GRADIENT ROXO
            decoration: BoxDecoration(
              color: primary,
            ),

            accountName: Text(
              name,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            accountEmail: Text(
              "Bem-vindo 👋",
              style: TextStyle(
                color: Colors.white70,
              ),
            ),

            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                size: 40,
                color: primary,
              ),
            ),
          ),

          // MODO ESCURO
          SwitchListTile(
            title: Text(
              "Modo escuro",
              style: TextStyle(
                color: textColor,
              ),
            ),
            value: isDark,
            onChanged: onThemeChanged,
            activeColor: primary,
            secondary: Icon(
              Icons.dark_mode,
              color: primary,
            ),
          ),

          Divider(),

          // CALENDÁRIO
          ListTile(
            leading: Icon(
              Icons.calendar_month,
              color: primary,
            ),
            title: Text(
              "Calendário",
              style: TextStyle(
                color: textColor,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CalendarScreen(
                    isParent: isParent,
                  ),
                ),
              );
            },
          ),

          // SOBRE
          ListTile(
            leading: Icon(
              Icons.info,
              color: primary,
            ),
            title: Text(
              "Sobre o app",
              style: TextStyle(
                color: textColor,
              ),
            ),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "Gerenciador de Tarefas",
                applicationVersion: "1.0.0",
                children: [
                  Text(
                    "Sistema de tarefas com recompensas.",
                  ),
                ],
              );
            },
          ),

          Spacer(),

          // LOGOUT
          ListTile(
            leading: Icon(
              Icons.logout,
              color: Colors.red,
            ),
            title: Text(
              "Sair",
              style: TextStyle(
                color: textColor,
              ),
            ),
            onTap: () async {
              await FirebaseAuth.instance.signOut();

              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
