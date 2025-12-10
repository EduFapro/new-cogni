import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/auth_providers.dart';

class ForgotPasswordDialog extends ConsumerStatefulWidget {
  const ForgotPasswordDialog({super.key});

  @override
  ConsumerState<ForgotPasswordDialog> createState() =>
      _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends ConsumerState<ForgotPasswordDialog> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _message;
  bool _isError = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _message = null;
      _isError = false;
    });

    try {
      final authRepo = await ref.read(authRepositoryProvider.future);
      final success = await authRepo.requestPasswordReset(
        _emailController.text.trim(),
      );

      setState(() {
        if (success) {
          _message = 'Se o e-mail existir, um link de redefinição foi enviado.';
          _isError = false;
        } else {
          _message = 'Falha ao solicitar redefinição. Tente novamente.';
          _isError = true;
        }
      });
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
    return ContentDialog(
      title: const Text('Esqueceu a Senha?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_message != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: InfoBar(
                title: Text(_isError ? 'Erro' : 'Informação'),
                content: Text(_message!),
                severity: _isError
                    ? InfoBarSeverity.error
                    : InfoBarSeverity.success,
              ),
            ),
          const Text(
            'Digite seu e-mail para receber um link de redefinição de senha.',
          ),
          const SizedBox(height: 16),
          InfoLabel(
            label: 'E-mail',
            child: TextBox(
              controller: _emailController,
              placeholder: 'seu@email.com',
            ),
          ),
          const SizedBox(height: 16),
          HyperlinkButton(
            child: const Text('Já tenho um token'),
            onPressed: () {
              Navigator.pop(context);
              context.push('/reset-password');
            },
          ),
        ],
      ),
      actions: [
        Button(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: ProgressRing(strokeWidth: 2.5),
                )
              : const Text('Enviar'),
        ),
      ],
    );
  }
}
