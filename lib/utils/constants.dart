class AppConstants {
  static const String appName = 'Gerenciador de Tarefas';
  static const String appVersion = '1.0.0';

  // Chaves para SharedPreferences
  static const String keyUserId = 'user_id';
  static const String keyUserRole = 'user_role';
  static const String keyUserName = 'user_name';
  static const String keyIsDarkMode = 'is_dark_mode';
  static const String keyFamilyCode = 'family_code';

  // Configurações
  static const int maxTaskPoints = 100;
  static const int minTaskPoints = 1;
  static const int defaultWaterGoal = 2000; // ml
  static const int waterIncrement = 200; // ml
}
