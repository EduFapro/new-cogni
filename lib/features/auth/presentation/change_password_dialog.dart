import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_providers.dart';

class ChangePasswordDialog extends ConsumerStatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  ConsumerState<ChangePasswordDialog> createState() =>
      _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<ChangePasswordDialog> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        _isLoading = false;
        _error = 'As senhas não coincidem.';
      });
      return;
    }

    try {
      final authRepo = await ref.read(authRepositoryProvider.future);
      final success = await authRepo.changePassword(
        _oldPasswordController.text,
        _newPasswordController.text,
      );

      if (success) {
        if (mounted) Navigator.pop(context);
      } else {
        setState(() {
          _error = 'Falha ao alterar senha. Verifique sua senha atual.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erro: $e';
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
      title: const Text('Alterar Senha'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: InfoBar(
                title: const Text('Erro'),
                content: Text(_error!),
                severity: InfoBarSeverity.error,
              ),
            ),
          InfoLabel(
            label: 'Senha Atual',
            child: PasswordBox(
              controller: _oldPasswordController,
              placeholder: 'Digite sua senha atual',
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
              : const Text('Alterar Senha'),
        ),
      ],
    );
  }
}
