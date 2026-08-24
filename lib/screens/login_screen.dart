import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/cache_service.dart';
import '../utils/validators.dart';
import '../widgets/loading_widget.dart';
import 'register_screen.dart';

/// Tela de Login do aplicativo
/// Responsável por autenticar o usuário e redirecionar para a tela correta
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// Serviço de autenticação (Firebase Auth)
  final AuthService authService = AuthService();

  /// Serviço de cache local (SharedPreferences)
  /// Já foi inicializado no main.dart
  final CacheService cache = CacheService();

  /// Controladores dos campos de texto
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  /// Controla se o loading está ativo
  bool isLoading = false;

  /// Controla se a senha está visível ou oculta
  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Ao abrir a tela, verifica se já existe um login salvo
    _checkAutoLogin();
  }

  /// Verifica se o usuário já está logado (cache)
  /// Se estiver, redireciona automaticamente
  Future<void> _checkAutoLogin() async {
    // cache.isLoggedIn verifica se existe userId salvo
    if (cache.isLoggedIn) {
      // Navega para a tela correta baseado no papel (role)
      await _navigateBasedOnRole(cache.userId, cache.userRole);
    }
  }

  /// Navega para a tela correta baseado no papel do usuário
  /// - 'parent' → Tela dos Pais
  /// - 'child' → Tela dos Filhos
  Future<void> _navigateBasedOnRole(String userId, String role) async {
    if (role == 'parent') {
      Navigator.pushReplacementNamed(context, '/parent');
    } else if (role == 'child') {
      Navigator.pushReplacementNamed(context, '/child');
    }
  }

  /// Realiza o login do usuário
  Future<void> _login() async {
    // Valida os campos antes de prosseguir
    if (!_validateFields()) return;

    // Ativa o loading
    setState(() => isLoading = true);

    try {
      // Autentica no Firebase com email e senha
      final user = await authService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      // Busca os dados do usuário no Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      // Verifica se o documento existe
      if (!userDoc.exists) {
        throw Exception('Usuário não encontrado');
      }

      // Extrai os dados do documento
      final data = userDoc.data() as Map<String, dynamic>;
      final role = data['role'] ?? 'child';

      // Salva os dados no cache local
      await cache.saveUserData(
        userId: user.uid,
        role: role,
        name: data['name'] ?? 'Usuário',
        familyCode: data['familyCode'] ?? '',
      );

      // Verifica se o widget ainda está montado (evita erros)
      if (!mounted) return;

      // Redireciona para a tela correta
      await _navigateBasedOnRole(user.uid, role);
    } catch (e) {
      // Em caso de erro, exibe mensagem
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao fazer login: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      // Desativa o loading
      if (mounted) setState(() => isLoading = false);
    }
  }

  /// Valida os campos de email e senha
  /// Retorna true se todos os campos são válidos
  bool _validateFields() {
    // Usa o Validators para verificar o email
    final emailError = Validators.validateEmail(emailController.text);
    // Usa o Validators para verificar a senha
    final passwordError = Validators.validatePassword(passwordController.text);

    // Se houver erro no email, exibe e retorna false
    if (emailError != null) {
      _showError(emailError);
      return false;
    }

    // Se houver erro na senha, exibe e retorna false
    if (passwordError != null) {
      _showError(passwordError);
      return false;
    }

    // Todos os campos são válidos
    return true;
  }

  /// Exibe uma mensagem de erro em um SnackBar
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadingWidget(
        // Exibe loading enquanto isLoading for true
        isLoading: isLoading,
        message: 'Entrando...',
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Ícone principal
                  Icon(
                    Icons.task_alt,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 20),

                  // Título
                  Text(
                    "Bem-vindo",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtítulo
                  Text(
                    "Gerencie suas tarefas e recompensas",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Campo de Email
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 15),

                  // Campo de Senha com ícone de visibilidade
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: "Senha",
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          // Alterna entre olho aberto/fechado
                          obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          // Alterna a visibilidade da senha
                          setState(() => obscurePassword = !obscurePassword);
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    obscureText: obscurePassword,
                  ),
                  const SizedBox(height: 25),

                  // Botão de Login
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      // Desabilita o botão enquanto isLoading
                      onPressed: isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Entrar",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Link para criar conta
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterScreen(),
                        ),
                      );
                    },
                    child: Text("Criar conta"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
