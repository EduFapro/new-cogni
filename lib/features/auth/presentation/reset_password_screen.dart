import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/auth_providers.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _tokenController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _message;
  bool _isError = false;

  @override
  void dispose() {
    _tokenController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _message = null;
      _isError = false;
    });

    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        _isLoading = false;
        _message = 'As senhas não coincidem.';
        _isError = true;
      });
      return;
    }

    try {
      final authRepo = await ref.read(authRepositoryProvider.future);
      final success = await authRepo.resetPassword(
        _tokenController.text.trim(),
        _newPasswordController.text,
      );

      setState(() {
        if (success) {
          _message =
              'Senha redefinida com sucesso! Você pode fazer login agora.';
          _isError = false;
        } else {
          _message = 'Falha ao redefinir senha. Token inválido ou expirado.';
          _isError = true;
        }
      });

      if (success) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) context.go('/login');
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Erro: $e';
        _isError = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: const PageHeader(
        title: Padding(
          padding: EdgeInsets.only(left: 12.0),
          child: Text('Redefinir Senha'),
        ),
      ),
      content: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_message != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: InfoBar(
                    title: Text(_isError ? 'Erro' : 'Sucesso'),
                    content: Text(_message!),
                    severity: _isError
                        ? InfoBarSeverity.error
                        : InfoBarSeverity.success,
                  ),
                ),
              InfoLabel(
                label: 'Token',
                child: TextBox(
                  controller: _tokenController,
                  placeholder: 'Cole o token recebido por e-mail',
                ),
              ),
              const SizedBox(height: 16),
              InfoLabel(
                label: 'Nova Senha',
                child: PasswordBox(
                  controller: _newPasswordController,
                  placeholder: 'Digite sua nova senha',
                ),
              ),
              const SizedBox(height: 16),
              InfoLabel(
                label: 'Confirmar Nova Senha',
                child: PasswordBox(
                  controller: _confirmPasswordController,
                  placeholder: 'Confirme sua nova senha',
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Button(
                    onPressed: _isLoading ? null : () => context.go('/login'),
                    child: const Text('Voltar ao Login'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: ProgressRing(strokeWidth: 2.5),
                          )
                        : const Text('Redefinir Senha'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
