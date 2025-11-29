import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/constants/enums/laterality_enums.dart';
import '../../../core/constants/enums/person_enums.dart';
import '../../../core/logger/app_logger.dart';
import '../domain/participant_entity.dart';
import '../presentation/participant_provider.dart';
import '../presentation/participant_list_provider.dart';

class EditParticipantDialog extends HookConsumerWidget {
  final ParticipantEntity participant;

  const EditParticipantDialog({super.key, required this.participant});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController(text: participant.name);
    final surnameController = useTextEditingController(
      text: participant.surname,
    );

    final birthDate = useState<DateTime?>(participant.birthDate);
    final selectedGender = useState<Sex?>(participant.sex);
    final selectedEducation = useState<EducationLevel?>(
      participant.educationLevel,
    );
    final selectedLaterality = useState<Laterality?>(participant.laterality);

    final isSaving = useState<bool>(false);

    Future<void> _onSave() async {
      if (!formKey.currentState!.validate() ||
          birthDate.value == null ||
          selectedGender.value == null ||
          selectedEducation.value == null ||
          selectedLaterality.value == null) {
        await showDialog(
          context: context,
          builder: (context) => ContentDialog(
            title: const Text('Dados incompletos'),
            content: const Text('Por favor, preencha todos os campos.'),
            actions: [
              FilledButton(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
        return;
      }

      isSaving.value = true;

      try {
        final updatedParticipant = participant.copyWith(
          name: nameController.text.trim(),
          surname: surnameController.text.trim(),
          birthDate: birthDate.value,
          sex: selectedGender.value,
          educationLevel: selectedEducation.value,
          laterality: selectedLaterality.value,
        );

        final repo = ref.read(participantRepositoryProvider);
        await repo.updateParticipant(updatedParticipant);

        AppLogger.info('✅ Participante atualizado com sucesso!');

        // Refresh the participant list
        ref.invalidate(participantListProvider);

        if (context.mounted) {
          Navigator.of(context).pop(); // Close dialog

          // Show success message
          await showDialog(
            context: context,
            builder: (context) => ContentDialog(
              title: const Text('Sucesso!'),
              content: const Text('Participante atualizado com sucesso.'),
              actions: [
                FilledButton(
                  child: const Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        }
      } catch (e, s) {
        AppLogger.error('❌ Erro ao atualizar participante', e, s);

        if (context.mounted) {
          await showDialog(
            context: context,
            builder: (context) => ContentDialog(
              title: const Text('Erro'),
              content: Text('Não foi possível atualizar: $e'),
              actions: [
                FilledButton(
                  child: const Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        }
      } finally {
        if (context.mounted) {
          isSaving.value = false;
        }
      }
    }

    return ContentDialog(
      title: const Text('Editar Participante'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              InfoLabel(
                label: 'Nome',
                child: TextBox(controller: nameController, placeholder: 'Nome'),
              ),
              const SizedBox(height: 12),

              InfoLabel(
                label: 'Sobrenome',
                child: TextBox(
                  controller: surnameController,
                  placeholder: 'Sobrenome',
                ),
              ),
              const SizedBox(height: 12),

              InfoLabel(
                label: 'Data de Nascimento',
                child: DatePicker(
                  selected: birthDate.value,
                  onChanged: (date) => birthDate.value = date,
                ),
              ),
              const SizedBox(height: 12),

              InfoLabel(
                label: 'Sexo',
                child: ComboBox<Sex>(
                  isExpanded: true,
                  value: selectedGender.value,
                  items: Sex.values
                      .map((g) => ComboBoxItem(value: g, child: Text(g.label)))
                      .toList(),
                  onChanged: (v) => selectedGender.value = v,
                  placeholder: const Text('Selecione o sexo'),
                ),
              ),
              const SizedBox(height: 12),

              InfoLabel(
                label: 'Nível de Educação',
                child: ComboBox<EducationLevel>(
                  isExpanded: true,
                  value: selectedEducation.value,
                  items: EducationLevel.values
                      .map((e) => ComboBoxItem(value: e, child: Text(e.label)))
                      .toList(),
                  onChanged: (v) => selectedEducation.value = v,
                  placeholder: const Text('Selecione o nível'),
                ),
              ),
              const SizedBox(height: 12),

              InfoLabel(
                label: 'Lateralidade',
                child: ComboBox<Laterality>(
                  isExpanded: true,
                  value: selectedLaterality.value,
                  items: Laterality.values
                      .map((h) => ComboBoxItem(value: h, child: Text(h.label)))
                      .toList(),
                  onChanged: (v) => selectedLaterality.value = v,
                  placeholder: const Text('Selecione a lateralidade'),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Button(
          onPressed: isSaving.value ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: isSaving.value ? null : _onSave,
          child: isSaving.value
              ? const SizedBox(width: 16, height: 16, child: ProgressRing())
              : const Text('Salvar'),
        ),
      ],
    );
  }
}
