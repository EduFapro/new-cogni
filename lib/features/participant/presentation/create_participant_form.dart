import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';

class ParticipantRegistrationForm extends HookWidget {
  const ParticipantRegistrationForm({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = useTextEditingController();
    final surnameController = useTextEditingController();
    final birthDate = useState<DateTime?>(null);
    final evaluationDate = useState<DateTime?>(null);
    final selectedGender = useState<String?>(null);
    final educationLevel = useState<String?>(null);
    final handedness = useState<String?>(null);
    final flyoutController = useMemoized(() => FlyoutController());

    final genders = ['Masculino', 'Feminino', 'Outro'];
    final educationLevels = ['Graduação', 'Mestrado', 'Doutorado'];
    final handednessOptions = ['Destro', 'Canhoto', 'Ambidestro'];

    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📋 Registro do Paciente',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
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
            child: ComboBox<String>(
              isExpanded: true,
              value: selectedGender.value,
              items: genders.map((g) => ComboBoxItem(value: g, child: Text(g))).toList(),
              onChanged: (v) => selectedGender.value = v,
              placeholder: const Text('Selecione o sexo'),
            ),
          ),
          const SizedBox(height: 12),

          InfoLabel(
            label: 'Nível de Educação',
            child: ComboBox<String>(
              isExpanded: true,
              value: educationLevel.value,
              items: educationLevels.map((e) => ComboBoxItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => educationLevel.value = v,
              placeholder: const Text('Selecione o nível'),
            ),
          ),
          const SizedBox(height: 12),

          InfoLabel(
            label: 'Lateralidade',
            child: ComboBox<String>(
              isExpanded: true,
              value: handedness.value,
              items: handednessOptions.map((h) => ComboBoxItem(value: h, child: Text(h))).toList(),
              onChanged: (v) => handedness.value = v,
              placeholder: const Text('Selecione a lateralidade'),
            ),
          ),
          const SizedBox(height: 12),

          InfoLabel(
            label: 'Data da Avaliação',
            child: DatePicker(
              selected: evaluationDate.value,
              onChanged: (date) => evaluationDate.value = date,
            ),
          ),
          const SizedBox(height: 12),

          if (evaluationDate.value != null)
            Text(
              '📅 Dia da semana: ${DateFormat('EEEE', 'pt_BR').format(evaluationDate.value!)}',
              style: const TextStyle(fontSize: 14),
            ),
          const SizedBox(height: 24),

          FlyoutTarget(
            controller: flyoutController,
            child: FilledButton(
              child: const Text('Salvar'),
              onPressed: () async {
                await flyoutController.showFlyout(
                  barrierDismissible: true,
                  placementMode: FlyoutPlacementMode.bottomCenter,
                  builder: (context) {
                    return FlyoutContent(
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('✅ Paciente registrado com sucesso!'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
