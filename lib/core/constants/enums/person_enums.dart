enum EducationLevel {
  incompleteElementary(1, "Fundamental Incompleto"),
  completeElementary(2, "Fundamental Completo"),
  incompleteHighSchool(3, "Médio Incompleto"),
  completeHighSchool(4, "Médio Completo"),
  incompleteCollege(5, "Superior Incompleto"),
  completeCollege(6, "Superior Completo"),
  postgraduate(7, "Pós-graduação"),
  master(8, "Mestrado"), // Optional
  doctorate(9, "Doutorado"); // Optional

  final int numericValue;
  final String description;

  const EducationLevel(this.numericValue, this.description);

  static EducationLevel fromValue(int value) {
    return EducationLevel.values.firstWhere(
      (level) => level.numericValue == value,
      orElse: () => EducationLevel.completeElementary,
    );
  }

  static EducationLevel fromLabel(String label) {
    switch (label.toLowerCase()) {
      case 'graduação':
        return EducationLevel.completeCollege;
      case 'mestrado':
        return EducationLevel.master;
      case 'doutorado':
        return EducationLevel.doctorate;
      default:
        return EducationLevel.completeElementary;
    }
  }

  String get label {
    switch (this) {
      case EducationLevel.master:
        return 'Mestrado';
      case EducationLevel.doctorate:
        return 'Doutorado';
      case EducationLevel.completeCollege:
        return 'Graduação';
      default:
        return description;
    }
  }
}

enum Sex {
  male(1, "Masculino"),
  female(2, "Feminino"),
  other(3, "Outro");

  final int numericValue;
  final String description;

  const Sex(this.numericValue, this.description);

  static Sex fromValue(int value) {
    return Sex.values.firstWhere(
      (s) => s.numericValue == value,
      orElse: () => Sex.other,
    );
  }

  static Sex fromString(String str) {
    switch (str.toLowerCase()) {
      case 'male':
        return Sex.male;
      case 'female':
        return Sex.female;
      case 'other':
        return Sex.other;
      default:
        return Sex.other;
    }
  }

  static Sex fromLabel(String label) {
    switch (label.toLowerCase()) {
      case 'masculino':
        return Sex.male;
      case 'feminino':
        return Sex.female;
      case 'outro':
        return Sex.other;
      default:
        return Sex.other;
    }
  }

  String get label {
    switch (this) {
      case Sex.male:
        return 'Masculino';
      case Sex.female:
        return 'Feminino';
      case Sex.other:
        return 'Outro';
    }
  }
}
