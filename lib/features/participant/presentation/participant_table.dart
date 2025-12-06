import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/constants/enums/progress_status.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/file_helper.dart';
import '../../../providers/evaluator_providers.dart';
import '../../evaluation/presentation/module_evaluation_screen.dart';
import '../../module_instance/presentation/module_instance_provider.dart';
import '../domain/participant_with_evaluation.dart';
import 'edit_participant_dialog.dart';
import '../../task_instance/domain/task_instance_providers.dart';
import '../../task_instance/domain/task_instance_entity.dart';
import '../../module_instance/domain/module_instance_entity.dart';

class ParticipantTable extends ConsumerStatefulWidget {
  final List<ParticipantWithEvaluation> participants;

  const ParticipantTable({super.key, required this.participants});

  @override
  ConsumerState<ParticipantTable> createState() => _ParticipantTableState();
}

class _ParticipantTableState extends ConsumerState<ParticipantTable> {
  final Set<int> _expandedRows = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: const BoxDecoration(
            color: AppColors.indigoBlue,
            border: Border(
              bottom: BorderSide(color: AppColors.coolGray500, width: 1),
            ),
          ),
          child: const Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'Paciente',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(flex: 2, child: Text('Status')),
              Expanded(flex: 5, child: Text('Ações')),
            ],
          ),
        ),

        // Participant rows
        ...widget.participants.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isExpanded = _expandedRows.contains(index);

          return Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.coolGray500, width: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Main row
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      // Name
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                isExpanded
                                    ? FluentIcons.chevron_up
                                    : FluentIcons.chevron_down,
                                size: 12,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (isExpanded) {
                                    _expandedRows.remove(index);
                                  } else {
                                    _expandedRows.add(index);
                                  }
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            Text(
                              item.fullName,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),

                      // Status
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.isCompleted ? '✅ Feita' : '⏳ Pendente',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),

                      // Action buttons
                      Expanded(
                        flex: 5,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            // 1. Prosseguir com Avaliação
                            FilledButton(
                              style: ButtonStyle(
                                backgroundColor: ButtonState.all(
                                  AppColors.accentOrange,
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  FluentPageRoute(
                                    builder: (_) => ModuleEvaluationScreen(
                                      evaluationId:
                                          item.evaluation!.evaluationID!,
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                'Prosseguir com Avaliação',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            // 2. Mais Informações
                            Button(
                              onPressed: () {
                                setState(() {
                                  if (isExpanded) {
                                    _expandedRows.remove(index);
                                  } else {
                                    _expandedRows.add(index);
                                  }
                                });
                              },
                              child: Text(
                                isExpanded
                                    ? 'Ocultar Informações'
                                    : 'Mais Informações',
                                style: TextStyle(
                                  color: isExpanded
                                      ? AppColors.coolGray500
                                      : Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            // 3. Editar Informações
                            Button(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => EditParticipantDialog(
                                    participant: item.participant,
                                  ),
                                );
                              },
                              child: Text(
                                'Editar Informações',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            // 4. Exportar Excel
                            Button(
                              onPressed: () async {
                                // Get current evaluator name
                                final evaluator = ref.read(currentUserProvider);
                                final evaluatorName = evaluator != null
                                    ? '${evaluator.name}${evaluator.surname}'
                                    : null;

                                // Fetch modules
                                final modules = await ref.read(
                                  moduleInstancesByEvaluationProvider(
                                    item.evaluation!.evaluationID!,
                                  ).future,
                                );

                                // Fetch tasks for each module
                                final tasksByModule =
                                    <int, List<TaskInstanceEntity>>{};
                                final taskRepo = ref.read(
                                  taskInstanceRepositoryProvider,
                                );

                                for (final module in modules) {
                                  if (module.id != null) {
                                    final tasks = await taskRepo
                                        .getByModuleInstance(module.id!);
                                    tasksByModule[module.id!] = tasks;
                                  }
                                }

                                await exportSingleParticipantToExcel(
                                  item,
                                  evaluatorName: evaluatorName,
                                  modules: modules,
                                  tasksByModule: tasksByModule,
                                );

                                if (context.mounted) {
                                  showDialog(
                                    context: context,
                                    builder: (_) => ContentDialog(
                                      title: const Text('Exportado!'),
                                      content: const Text(
                                        'Participante exportado com sucesso.',
                                      ),
                                      actions: [
                                        Button(
                                          child: const Text('OK'),
                                          onPressed: () =>
                                              Navigator.pop(context),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                              child: Text(
                                'Exportar Excel',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Expanded content (accordion)
                if (isExpanded)
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: const Border(
                        top: BorderSide(
                          color: AppColors.coolGray500,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: _buildEvaluationDetails(item),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEvaluationDetails(ParticipantWithEvaluation item) {
    if (item.evaluation == null) {
      return const Text(
        'Nenhuma avaliação encontrada para este participante.',
        style: TextStyle(fontStyle: FontStyle.italic),
      );
    }

    return Consumer(
      builder: (context, ref, _) {
        final modulesAsync = ref.watch(
          moduleInstancesByEvaluationProvider(item.evaluation!.evaluationID!),
        );

        return modulesAsync.when(
          data: (modules) {
            final totalModules = modules.length;
            final completedModules = modules
                .where((m) => m.status == ModuleStatus.completed)
                .length;
            final progressPercent = totalModules > 0
                ? ((completedModules / totalModules) * 100).toStringAsFixed(0)
                : '0';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Dados Pessoais
                const Text(
                  'Dados Pessoais',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.indigoBlue,
                  ),
                ),
                const SizedBox(height: 8),
                _buildInfoRow('Nome Completo:', item.fullName),
                _buildInfoRow(
                  'Data de Nascimento:',
                  DateFormat('dd/MM/yyyy').format(item.participant.birthDate),
                ),
                _buildInfoRow('Sexo:', item.participant.sex.label),
                _buildInfoRow(
                  'Escolaridade:',
                  item.participant.educationLevel.label,
                ),
                _buildInfoRow(
                  'Lateralidade:',
                  item.participant.laterality.label,
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // 2. Detalhes da Avaliação
                const Text(
                  'Detalhes da Avaliação',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.indigoBlue,
                  ),
                ),
                const SizedBox(height: 12),

                // Evaluation info
                _buildInfoRow('Data de Início:', item.evaluationDateFormatted),
                _buildInfoRow('Status:', item.statusLabel),
                _buildInfoRow(
                  'Progresso:',
                  '$completedModules de $totalModules módulos concluídos ($progressPercent%)',
                ),

                const SizedBox(height: 16),

                // Module list
                if (modules.isNotEmpty) ...[
                  const Text(
                    'Módulos:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...modules.map((module) {
                    final statusIcon = module.status == ModuleStatus.completed
                        ? '✅'
                        : module.status == ModuleStatus.inProgress
                        ? '🔄'
                        : '⏳';
                    final statusText = module.status == ModuleStatus.completed
                        ? 'Concluído'
                        : module.status == ModuleStatus.inProgress
                        ? 'Em andamento'
                        : 'Pendente';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Row(
                        children: [
                          Text(statusIcon),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              module.module?.title ??
                                  'Módulo #${module.moduleId}',
                            ),
                          ),
                          Text(
                            statusText,
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            );
          },
          loading: () => const Center(child: ProgressRing()),
          error: (err, stack) => Text('Erro ao carregar módulos: $err'),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
