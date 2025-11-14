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
    final nameController = useTextEditingController();
    final surnameController = useTextEditingController();

    final birthDate = useState<DateTime?>(null);
    final evaluationDate = useState<DateTime?>(null);

    final selectedGender = useState<Sex?>(null);
    final selectedEducation = useState<EducationLevel?>(null);
    final selectedLaterality = useState<Laterality?>(null);

    final flyoutController = useMemoized(() => FlyoutController());

    final modulesState = useState<List<ModuleEntity>>([]);
    final selectedModuleIds = useState<Set<int>>({});
    final selectAll = useState<bool>(true);

    final createState = ref.watch(createParticipantEvaluationProvider);

    // Carrega os módulos na primeira renderização
    useEffect(() {
      () async {
        try {
          AppLogger.info('[UI] Carregando módulos...');
          final dbHelper = ref.read(participantDbHelperProvider);
          final moduleDs = ModuleLocalDataSource(dbHelper: dbHelper);
          final modules = await moduleDs.getAllModules();

          modulesState.value = modules;

          final ids = modules
              .where((m) => m.moduleID != null && m.moduleID != 9001)
              .map((m) => m.moduleID!)
              .toSet();

          selectedModuleIds.value = ids;
          selectAll.value = true;

          AppLogger.info('[UI] Módulos carregados: ${modules.length}, selecionados: ${ids.length}');
        } catch (e, s) {
          AppLogger.error('[UI] Erro ao carregar módulos', e, s);
        }
      }();
      return null;
    }, const []);

    Future<void> _showSuccessAndResetForm() async {
      AppLogger.info('[UI] ✅ Paciente criado com sucesso!');

      await flyoutController.showFlyout(
        barrierDismissible: true,
        placementMode: FlyoutPlacementMode.bottomCenter,
        builder: (context) => const FlyoutContent(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('✅ Paciente registrado com sucesso!'),
          ),
        ),
      );

      formKey.currentState!.reset();
      nameController.clear();
      surnameController.clear();
      birthDate.value = null;
      evaluationDate.value = null;
      selectedGender.value = null;
      selectedEducation.value = null;
      selectedLaterality.value = null;
    }

    Future<void> _onSubmit() async {
      if (!formKey.currentState!.validate() ||
          birthDate.value == null ||
          selectedGender.value == null ||
          selectedEducation.value == null ||
          selectedLaterality.value == null) {
        AppLogger.warning('[UI] Validação do formulário falhou');

        await showDialog(
          context: context,
          builder: (context) => ContentDialog(
            title: const Text('Dados incompletos'),
            content: const Text('Por favor, preencha todos os campos obrigatórios do paciente.'),
            actions: [FilledButton(child: const Text('OK'), onPressed: () => Navigator.pop(context))],
          ),
        );
        return;
      }

      if (selectedModuleIds.value.isEmpty) {
        AppLogger.warning('[UI] Nenhum módulo selecionado');

        await showDialog(
          context: context,
          builder: (context) => ContentDialog(
            title: const Text('Selecione os módulos'),
            content: const Text('Escolha pelo menos um módulo para esta avaliação.'),
            actions: [FilledButton(child: const Text('OK'), onPressed: () => Navigator.pop(context))],
          ),
        );
        return;
      }

      final evaluator = ref.read(currentUserProvider);
      if (evaluator == null || evaluator.evaluatorId == null) {
        AppLogger.error('[UI] Nenhum avaliador logado');

        await showDialog(
          context: context,
          builder: (context) => ContentDialog(
            title: const Text('Erro'),
            content: const Text('Nenhum avaliador logado foi encontrado. Faça login novamente.'),
            actions: [FilledButton(child: const Text('OK'), onPressed: () => Navigator.pop(context))],
          ),
        );
        return;
      }

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
        '[UI] Criando paciente → '
            'nome=${participant.name} ${participant.surname}, '
            'nascimento=${participant.birthDate}, '
            'sexo=${participant.sex}, '
            'educação=${participant.educationLevel}, '
            'lateralidade=${participant.laterality}, '
            'avaliadorId=${evaluator.evaluatorId}, '
            'módulos=$moduleIds',
      );

      try {
        final notifier = ref.read(createParticipantEvaluationProvider.notifier);

        await notifier.createParticipantWithEvaluation(
          participant: participant,
          evaluatorId: evaluator.evaluatorId!,
          selectedModuleIds: moduleIds,
        );

        final state = ref.read(createParticipantEvaluationProvider);
        if (state.hasError) {
          AppLogger.error('[UI] Falha ao criar paciente', state.error, state.stackTrace);
          await showDialog(
            context: context,
            builder: (context) => ContentDialog(
              title: const Text('Erro ao salvar'),
              content: const Text('Não foi possível registrar o paciente. Tente novamente.'),
              actions: [FilledButton(child: const Text('OK'), onPressed: () => Navigator.pop(context))],
            ),
          );
          return;
        }

        await _showSuccessAndResetForm();
      } catch (e, s) {
        AppLogger.error('[UI] Erro inesperado', e, s);
        await showDialog(
          context: context,
          builder: (context) => ContentDialog(
            title: const Text('Erro inesperado'),
            content: const Text('Ocorreu um erro inesperado. Verifique os logs.'),
            actions: [FilledButton(child: const Text('OK'), onPressed: () => Navigator.pop(context))],
          ),
        );
      }
    }

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📋 Registro do Paciente', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          TextBox(controller: nameController, placeholder: 'Nome'),
          const SizedBox(height: 12),

          TextBox(controller: surnameController, placeholder: 'Sobrenome'),
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
              items: Sex.values.map((g) => ComboBoxItem(value: g, child: Text(g.label))).toList(),
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
              items: EducationLevel.values.map((e) => ComboBoxItem(value: e, child: Text(e.label))).toList(),
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
              items: Laterality.values.map((h) => ComboBoxItem(value: h, child: Text(h.label))).toList(),
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
          if (evaluationDate.value != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '📅 Dia da semana: ${DateFormat('EEEE', 'pt_BR').format(evaluationDate.value!)}',
              ),
            ),

          const SizedBox(height: 24),

          Text('Módulos da Avaliação', style: FluentTheme.of(context).typography.subtitle),
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
                        .where((m) => m.moduleID != null && m.moduleID != 9001)
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
                    value == true ? set.add(id) : set.remove(id);
                    selectedModuleIds.value = set;

                    final totalVisible = modulesState.value
                        .where((m) => m.moduleID != null && m.moduleID != 9001)
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
