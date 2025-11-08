String parseLoginError(dynamic error) {
  final errStr = error.toString();

  if (errStr.contains('no such table: current_user')) {
    return 'Erro interno: tabela de usuário não encontrada. Tente reinstalar o app.';
  }

  if (errStr.contains('no column named')) {
    return 'Erro no banco de dados. Contate o suporte técnico.';
  }

  if (errStr.contains('DatabaseException')) {
    return 'Erro ao acessar o banco de dados. Tente novamente.';
  }

  if (errStr.contains('Credenciais inválidas')) {
    return 'E-mail ou senha incorretos.';
  }

  if (errStr.contains('Exception:')) {
    return errStr.replaceFirst('Exception:', '').trim();
  }

  // Default fallback
  return 'Erro inesperado. Verifique sua conexão ou tente novamente.';
}
