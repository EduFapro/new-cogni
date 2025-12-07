import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class CustomDatePicker extends HookWidget {
  final DateTime? selected;
  final ValueChanged<DateTime?> onChanged;
  final bool allowManual;

  const CustomDatePicker({
    super.key,
    required this.selected,
    required this.onChanged,
    this.allowManual = false,
  });

  @override
  Widget build(BuildContext context) {
    final isManualMode = useState(false);

    // Controllers for manual input
    final dayController = useTextEditingController(
      text: selected?.day.toString() ?? '',
    );
    final yearController = useTextEditingController(
      text: selected?.year.toString() ?? '',
    );
    final selectedMonth = useState<int>(selected?.month ?? 1);

    // Sync manual fields when switching back to manual or when external selected changes
    useEffect(() {
      if (selected != null) {
        if (dayController.text != selected!.day.toString()) {
          dayController.text = selected!.day.toString();
        }
        if (yearController.text != selected!.year.toString()) {
          yearController.text = selected!.year.toString();
        }
        selectedMonth.value = selected!.month;
      }
      return null;
    }, [selected]);

    void tryUpdateDate() {
      final day = int.tryParse(dayController.text);
      final year = int.tryParse(yearController.text);
      final month = selectedMonth.value;

      if (day != null && year != null) {
        try {
          // Validate date validity (e.g., Feb 30)
          final date = DateTime(year, month, day);
          if (date.year == year && date.month == month && date.day == day) {
            onChanged(date);
          } else {
            // Invalid date (e.g. 31st of Feb), don't update or maybe set to null
            // For now, we just don't update if it's strictly invalid logic
          }
        } catch (e) {
          // Ignore
        }
      }
    }

    if (!allowManual) {
      return DatePicker(selected: selected, onChanged: onChanged);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isManualMode.value) ...[
          DatePicker(selected: selected, onChanged: onChanged),
          const SizedBox(height: 4),
          HyperlinkButton(
            child: const Text(
              "Digitar data manualmente",
              style: TextStyle(
                decoration: TextDecoration.underline,
                fontSize: 12,
              ),
            ),
            onPressed: () => isManualMode.value = true,
          ),
        ] else ...[
          Row(
            children: [
              // Day
              SizedBox(
                width: 60,
                child: TextBox(
                  controller: dayController,
                  placeholder: 'Dia',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  onChanged: (_) => tryUpdateDate(),
                ),
              ),
              const SizedBox(width: 8),
              // Month
              ComboBox<int>(
                value: selectedMonth.value,
                items: List.generate(12, (index) {
                  final monthNum = index + 1;
                  // Simple month names or use intl
                  final monthName = _getMonthName(monthNum);
                  return ComboBoxItem(value: monthNum, child: Text(monthName));
                }),
                onChanged: (value) {
                  if (value != null) {
                    selectedMonth.value = value;
                    tryUpdateDate();
                  }
                },
              ),
              const SizedBox(width: 8),
              // Year
              SizedBox(
                width: 80,
                child: TextBox(
                  controller: yearController,
                  placeholder: 'Ano',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  onChanged: (_) => tryUpdateDate(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          HyperlinkButton(
            child: const Text(
              "Selecionar no calendário",
              style: TextStyle(
                decoration: TextDecoration.underline,
                fontSize: 12,
              ),
            ),
            onPressed: () => isManualMode.value = false,
          ),
        ],
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return months[month - 1];
  }
}
