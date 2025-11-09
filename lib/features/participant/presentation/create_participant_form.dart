import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/enums/laterality_enums.dart';
import '../../../core/constants/enums/person_enums.dart';

class ParticipantRegistrationForm extends HookWidget {
  const ParticipantRegistrationForm({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = useTextEditingController();
    final surnameController = useTextEditingController();
    final birthDate = useState<DateTime?>(null);
    final evaluationDate = useState<DateTime?>(null);

    final selectedGender = useState<Sex?>(null);
    final selectedEducation = useState<EducationLevel?>(null);
    final selectedLaterality = useState<Laterality?>(null);

    final flyoutController = useMemoized(() => FlyoutController());

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
                // Perform validation here (optional)
                if (nameController.text.isEmpty ||
                    surnameController.text.isEmpty ||
                    birthDate.value == null ||
                    selectedGender.value == null ||
                    selectedEducation.value == null ||
                    selectedLaterality.value == null) {
                  // Show error flyout or dialog
                  return;
                }

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

                // You can now use:
                // selectedGender.value!.numericValue
                // selectedEducation.value!.numericValue
                // selectedLaterality.value!.numericValue
              },
            ),
          ),
        ],
      ),
    );
  }
}
