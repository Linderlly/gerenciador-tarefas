import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/calendar_screen.dart';
import '../services/cache_service.dart';

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
            decoration: BoxDecoration(
              color: primary,
            ),
            accountName: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: const Text(
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
          const Divider(),
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
                children: const [
                  Text(
                    "Sistema de tarefas com recompensas.",
                  ),
                ],
              );
            },
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(
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
              // Isso remove os dados do usuário salvos no SharedPreferences
              // Evita que o app tente fazer login automático com dados antigos
              final cache = CacheService();
              await cache.clear();

              // Desconecta o usuário atual do Firebase Authentication
              await FirebaseAuth.instance.signOut();

              // pushNamedAndRemoveUntil: Remove todas as telas anteriores
              // (route) => false: Remove todas as rotas da pilha
              // Isso garante que o usuário não possa voltar para a tela anterior
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
