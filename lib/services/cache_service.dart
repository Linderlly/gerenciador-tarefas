import 'package:shared_preferences/shared_preferences.dart';

/// Serviço de cache local para armazenar dados do usuário
/// Utiliza SharedPreferences para persistir dados localmente
class CacheService {
  // Garante que apenas uma instância do CacheService exista
  // Isso evita múltiplas conexões com o SharedPreferences

  static final CacheService _instance = CacheService._internal();

  /// Fábrica para retornar a instância única
  factory CacheService() => _instance;

  /// Construtor privado (Singleton)
  CacheService._internal();

  /// Referência ao SharedPreferences
  /// late: será inicializado antes de ser usado
  /// _prefs: privado, só acessível dentro desta classe
  late SharedPreferences _prefs;

  /// Inicializa o SharedPreferences
  /// Deve ser chamado no main.dart antes de qualquer uso
  /// Future: operação assíncrona
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Salva todos os dados do usuário no cache local
  Future<void> saveUserData({
    required String userId,
    required String role,
    required String name,
    required String familyCode,
  }) async {
    await _prefs.setString('user_id', userId);
    await _prefs.setString('user_role', role);
    await _prefs.setString('user_name', name);
    await _prefs.setString('family_code', familyCode);
  }

  /// Retorna o ID do usuário ou string vazia se não existir
  String get userId => _prefs.getString('user_id') ?? '';

  /// Retorna o papel do usuário ('parent' ou 'child')
  String get userRole => _prefs.getString('user_role') ?? '';

  /// Retorna o nome do usuário ou 'Usuário' como fallback
  String get userName => _prefs.getString('user_name') ?? 'Usuário';

  /// Retorna o código da família ou string vazia
  String get familyCode => _prefs.getString('family_code') ?? '';

  /// Salva a preferência de tema do usuário
  /// - isDark: true para modo escuro, false para claro
  Future<void> saveThemeMode(bool isDark) async {
    await _prefs.setBool('is_dark_mode', isDark);
  }

  /// Retorna true se o modo escuro está ativado
  bool get isDarkMode => _prefs.getBool('is_dark_mode') ?? false;

  /// Remove todos os dados do cache (usado no logout)
  /// Limpa todas as chaves relacionadas ao usuário
  Future<void> clear() async {
    await _prefs.remove('user_id');
    await _prefs.remove('user_role');
    await _prefs.remove('user_name');
    await _prefs.remove('family_code');
    // Nota: is_dark_mode NÃO é removido para manter a preferência do tema
  }

  /// Verifica se o usuário está logado
  /// Retorna true se existe um userId salvo
  bool get isLoggedIn => userId.isNotEmpty;
}
