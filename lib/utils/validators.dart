class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira um e-mail';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Por favor, insira um e-mail válido';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira uma senha';
    }
    if (value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira um nome';
    }
    if (value.length < 2) {
      return 'Por favor, insira um nome válido';
    }
    return null;
  }

  static String? validatePoints(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira uma quantidade de pontos';
    }
    final points = int.tryParse(value);
    if (points == null) {
      return 'Por favor, insira um número válido';
    }
    if (points <= 0) {
      return 'Os pontos devem ser maiores que zero';
    }
    if (points > 100) {
      return 'Os pontos não podem ser maiores que 100';
    }
    return null;
  }
}
