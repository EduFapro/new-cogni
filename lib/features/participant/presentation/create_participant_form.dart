import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/enums/laterality_enums.dart';
import '../../../core/constants/enums/person_enums.dart';
import '../../../core/logger/app_logger.dart';
import '../../../providers/evaluator_providers.dart';
import '../../../providers/participant_providers.dart';
import '../domain/participant_entity.dart';

class ParticipantRegistrationForm extends HookConsumerWidget {
  const ParticipantRegistrationForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    final surnameController = useTextEditingController();
    final birthDate = useState<DateTime?>(null);
    final evaluationDate = useState<DateTime?>(null); // optional / future use

    final selectedGender = useState<Sex?>(null);
    final selectedEducation = useState<EducationLevel?>(null);
    final selectedLaterality = useState<Laterality?>(null);

    final flyoutController = useMemoized(() => FlyoutController());

    final createState = ref.watch(createParticipantEvaluationProvider);

    Future<void> _onSubmit() async {
      // 1) Validate fields
      if (nameController.text.trim().isEmpty ||
          surnameController.text.trim().isEmpty ||
          birthDate.value == null ||
          selectedGender.value == null ||
          selectedEducation.value == null ||
          selectedLaterality.value == null) {
        AppLogger.warning(
            '[UI] Participant form validation failed — missing required fields');
        await showDialog(
          context: context,
          builder: (context) => ContentDialog(
            title: const Text('Dados incompletos'),
            content: const Text(
                'Por favor, preencha todos os campos obrigatórios do paciente.'),
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

      // 2) Get logged evaluator
      final evaluator = ref.read(currentUserProvider);
      if (evaluator == null || evaluator.evaluatorId == null) {
        AppLogger.error(
          '[UI] Tried to create participant without a logged evaluator',
        );
        await showDialog(
          context: context,
          builder: (context) => ContentDialog(
            title: const Text('Erro'),
            content: const Text(
                'Nenhum avaliador logado foi encontrado. Faça login novamente.'),
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

      // 3) Build ParticipantEntity
      final participant = ParticipantEntity(
        name: nameController.text.trim(),
        surname: surnameController.text.trim(),
        birthDate: birthDate.value!,
        sex: selectedGender.value!,
        educationLevel: selectedEducation.value!,
        laterality: selectedLaterality.value!,
      );

      AppLogger.info(
        '[UI] Submitting participant creation → '
            'name=${participant.name} ${participant.surname}, '
            'birthDate=${participant.birthDate}, '
            'sex=${participant.sex}, '
            'education=${participant.educationLevel}, '
            'laterality=${participant.laterality}, '
            'evaluatorId=${evaluator.evaluatorId}',
      );

      // 4) Call notifier
      await ref
          .read(createParticipantEvaluationProvider.notifier)
          .createParticipantWithEvaluation(
        participant: participant,
        evaluatorId: evaluator.evaluatorId!,
      );

      final state = ref.read(createParticipantEvaluationProvider);

      // 5) Handle result
      if (state.hasError) {
        AppLogger.error(
          '[UI] Participant creation failed',
          state.error,
          state.stackTrace,
        );
        await showDialog(
          context: context,
          builder: (context) => ContentDialog(
            title: const Text('Erro ao salvar'),
            content: const Text(
                'Não foi possível registrar o paciente. Tente novamente.'),
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

      AppLogger.info('[UI] ✅ Participant created successfully — showing flyout');

      // Optionally use the evaluationDate in the future; currently EvaluationEntity
      // sets its own date in the use case.

      await flyoutController.showFlyout(
        barrierDismissible: true,
        placementMode: FlyoutPlacementMode.bottomCenter,
        builder: (context) {
          return const FlyoutContent(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('✅ Paciente registrado com sucesso!'),
            ),
          );
        },
      );

      // Clear form
      nameController.clear();
      surnameController.clear();
      birthDate.value = null;
      evaluationDate.value = null;
      selectedGender.value = null;
      selectedEducation.value = null;
      selectedLaterality.value = null;
    }

    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📋 Registro do Paciente',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          TextBox(
            controller: nameController,
            placeholder: 'Nome',
          ),
          const SizedBox(height: 12),

          TextBox(
            controller: surnameController,
            placeholder: 'Sobrenome',
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
          const SizedBox(height: 12),

          InfoLabel(
            label: 'Data da Avaliação (opcional)',
            child: DatePicker(
              selected: evaluationDate.value,
              onChanged: (date) => evaluationDate.value = date,
            ),
          ),
          if (evaluationDate.value != null) ...[
            const SizedBox(height: 8),
            Text(
              '📅 Dia da semana: '
                  '${DateFormat('EEEE', 'pt_BR').format(evaluationDate.value!)}',
            ),
          ],
          const SizedBox(height: 24),

          FlyoutTarget(
            controller: flyoutController,
            child: FilledButton(
              onPressed:
              createState.isLoading ? null : () => _onSubmit(),
              child: createState.isLoading
                  ? const ProgressRing()
                  : const Text('Salvar'),
            ),
          ),
        ],
      ),
    );
  }
}
