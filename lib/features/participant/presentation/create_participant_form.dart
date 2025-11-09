import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/enums/laterality_enums.dart';
import '../../../core/constants/enums/person_enums.dart';
import '../../../core/logger/app_logger.dart';

import '../../../providers/evaluator_providers.dart';
import '../../../providers/participant_providers.dart';

import '../../module/data/module_local_datasource.dart';
import '../../module/domain/module_entity.dart';

import '../domain/participant_entity.dart';

class ParticipantRegistrationForm extends HookConsumerWidget {
  const ParticipantRegistrationForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    // --- Controllers / state ---
    final nameController = useTextEditingController();
    final surnameController = useTextEditingController();
    final birthDate = useState<DateTime?>(null);
    final evaluationDate = useState<DateTime?>(null);

    final selectedGender = useState<Sex?>(null);
    final selectedEducation = useState<EducationLevel?>(null);
    final selectedLaterality = useState<Laterality?>(null);

    final flyoutController = useMemoized(() => FlyoutController());

    // --- Modules selection state ---
    final modulesState = useState<List<ModuleEntity>>([]);
    final selectedModuleIds = useState<Set<int>>({});
    final selectAll = useState<bool>(true);

    final createState = ref.watch(createParticipantEvaluationProvider);

    // Load modules once
    useEffect(() {
      () async {
        try {
          final dbHelper = ref.read(participantDbHelperProvider);
          final moduleDs = ModuleLocalDataSource(dbHelper: dbHelper);
          final modules = await moduleDs.getAllModules();

          modulesState.value = modules;

          // Default: all real modules selected (ignore testsModuleId == 9001)
          final ids = modules
              .where((m) => m.moduleID != null && m.moduleID != 9001)
              .map((m) => m.moduleID!)
              .toSet();

          selectedModuleIds.value = ids;
          selectAll.value = true;

          AppLogger.info(
            '[UI] Loaded ${modules.length} modules for selection '
                '(default selected=${ids.length})',
          );
        } catch (e, s) {
          AppLogger.error('[UI] Failed to load modules', e, s);
        }
      }();
      return null;
    }, const []);

    Future<void> _onSubmit() async {
      // Validate
      if (!formKey.currentState!.validate() ||
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

      // Need at least one module
      if (selectedModuleIds.value.isEmpty) {
        await showDialog(
          context: context,
          builder: (context) => ContentDialog(
            title: const Text('Selecione os módulos'),
            content: const Text(
                'Escolha pelo menos um módulo para esta avaliação.'),
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

      // Logged evaluator
      final evaluator = ref.read(currentUserProvider);
      if (evaluator == null || evaluator.evaluatorId == null) {
        AppLogger.error(
            '[UI] Tried to create participant without a logged evaluator');
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

      // Build entity
      final participant = ParticipantEntity(
        name: nameController.text.trim(),
        surname: surnameController.text.trim(),
        birthDate: birthDate.value!,
        sex: selectedGender.value!,
        educationLevel: selectedEducation.value!,
        laterality: selectedLaterality.value!,
      );

      final moduleIds = selectedModuleIds.value.toList();

      AppLogger.info(
        '[UI] Submitting participant creation → '
            'name=${participant.name} ${participant.surname}, '
            'birthDate=${participant.birthDate}, '
            'sex=${participant.sex}, '
            'education=${participant.educationLevel}, '
            'laterality=${participant.laterality}, '
            'evaluatorId=${evaluator.evaluatorId}, '
            'modules=$moduleIds',
      );

      // Call notifier
      await ref
          .read(createParticipantEvaluationProvider.notifier)
          .createParticipantWithEvaluation(
        participant: participant,
        evaluatorId: evaluator.evaluatorId!,
        selectedModuleIds: moduleIds,
      );

      final state = ref.read(createParticipantEvaluationProvider);

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

      AppLogger.info(
          '[UI] ✅ Participant created successfully — showing confirmation');

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

      // Reset form
      formKey.currentState!.reset();
      nameController.clear();
      surnameController.clear();
      birthDate.value = null;
      evaluationDate.value = null;
      selectedGender.value = null;
      selectedEducation.value = null;
      selectedLaterality.value = null;

      // Keep modules selected as-is, or reset if you prefer
    }

    // --- UI ---

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📋 Registro do Paciente',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Nome
          TextBox(
            controller: nameController,
            placeholder: 'Nome',
            onChanged: (_) => formKey.currentState!.validate(),
          ),
          const SizedBox(height: 12),

          // Sobrenome
          TextBox(
            controller: surnameController,
            placeholder: 'Sobrenome',
            onChanged: (_) => formKey.currentState!.validate(),
          ),
          const SizedBox(height: 12),

          // Data de nascimento
          InfoLabel(
            label: 'Data de Nascimento',
            child: DatePicker(
              selected: birthDate.value,
              onChanged: (date) {
                birthDate.value = date;
                formKey.currentState!.validate();
              },
            ),
          ),
          const SizedBox(height: 12),

          // Sexo
          InfoLabel(
            label: 'Sexo',
            child: ComboBox<Sex>(
              isExpanded: true,
              value: selectedGender.value,
              items: Sex.values
                  .map((g) => ComboBoxItem(value: g, child: Text(g.label)))
                  .toList(),
              onChanged: (v) {
                selectedGender.value = v;
                formKey.currentState!.validate();
              },
              placeholder: const Text('Selecione o sexo'),
            ),
          ),
          const SizedBox(height: 12),

          // Educação
          InfoLabel(
            label: 'Nível de Educação',
            child: ComboBox<EducationLevel>(
              isExpanded: true,
              value: selectedEducation.value,
              items: EducationLevel.values
                  .map((e) => ComboBoxItem(value: e, child: Text(e.label)))
                  .toList(),
              onChanged: (v) {
                selectedEducation.value = v;
                formKey.currentState!.validate();
              },
              placeholder: const Text('Selecione o nível'),
            ),
          ),
          const SizedBox(height: 12),

          // Lateralidade
          InfoLabel(
            label: 'Lateralidade',
            child: ComboBox<Laterality>(
              isExpanded: true,
              value: selectedLaterality.value,
              items: Laterality.values
                  .map((h) => ComboBoxItem(value: h, child: Text(h.label)))
                  .toList(),
              onChanged: (v) {
                selectedLaterality.value = v;
                formKey.currentState!.validate();
              },
              placeholder: const Text('Selecione a lateralidade'),
            ),
          ),
          const SizedBox(height: 12),

          // Data avaliação (opcional)
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

          // --- Módulos ---
          Text(
            'Módulos da Avaliação',
            style: FluentTheme.of(context).typography.subtitle,
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Checkbox(
                checked: selectAll.value,
                onChanged: (value) {
                  final v = value ?? false;
                  selectAll.value = v;

                  if (v) {
                    selectedModuleIds.value = modulesState.value
                        .where((m) =>
                    m.moduleID != null && m.moduleID != 9001)
                        .map((m) => m.moduleID!)
                        .toSet();
                  } else {
                    selectedModuleIds.value = {};
                  }
                },
              ),
              const SizedBox(width: 8),
              const Text('Selecionar todos'),
            ],
          ),

          const SizedBox(height: 8),

          ...modulesState.value
              .where((m) => m.moduleID != null && m.moduleID != 9001)
              .map((module) {
            final id = module.moduleID!;
            final isChecked = selectedModuleIds.value.contains(id);

            return Row(
              children: [
                Checkbox(
                  checked: isChecked,
                  onChanged: (value) {
                    final set = {...selectedModuleIds.value};
                    if (value == true) {
                      set.add(id);
                    } else {
                      set.remove(id);
                    }
                    selectedModuleIds.value = set;

                    // Keep selectAll in sync
                    final totalVisible = modulesState.value
                        .where((m) =>
                    m.moduleID != null && m.moduleID != 9001)
                        .length;
                    selectAll.value = set.length == totalVisible;
                  },
                ),
                const SizedBox(width: 8),
                Text(module.title),
              ],
            );
          }).toList(),

          const SizedBox(height: 24),

          // --- Submit ---
          FlyoutTarget(
            controller: flyoutController,
            child: FilledButton(
              onPressed: createState.isLoading ? null : _onSubmit,
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
