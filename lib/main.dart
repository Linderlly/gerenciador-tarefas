import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'theme/theme.dart';
import 'screens/login_screen.dart';
import 'screens/parent_screen.dart';
import 'screens/child_screen.dart';
import 'services/cache_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega variáveis de ambiente
  await dotenv.load(fileName: ".env");

  // INICIALIZAÇÃO DO FIREBASE
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await CacheService().init();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // CONTROLE DO MODO ESCURO
  bool isDark = false;

  // ALTERAÇÃO DE TEMA
  void toggleTheme(bool value) {
    setState(() {
      isDark = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tarefas dos Filhos',

      // REMOVE A FAIXA DEBUG
      debugShowCheckedModeBanner: false,

      // TEMA CLARO PERSONALIZADO
      theme: AppTheme.lightTheme,

      // TEMA ESCURO PERSONALIZADO
      darkTheme: AppTheme.darkTheme,

      // CONTROLE DO TEMA
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

      // ROTA INICIAL
      initialRoute: '/login',

      // ROTAS DO APP
      routes: {
        '/login': (context) => LoginScreen(),
        '/parent': (context) => ParentScreen(
              toggleTheme: toggleTheme,
              isDark: isDark,
            ),
        '/child': (context) => ChildScreen(
              toggleTheme: toggleTheme,
              isDark: isDark,
            ),
      },
    );
  }
}
