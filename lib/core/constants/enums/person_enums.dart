enum EducationLevel {
  incompleteElementary(1, "Incomplete Elementary"),
  completeElementary(2, "Complete Elementary"),
  incompleteHighSchool(3, "Incomplete High School"),
  completeHighSchool(4, "Complete High School"),
  incompleteCollege(5, "Incomplete College"),
  completeCollege(6, "Complete College"),
  postgraduate(7, "Postgraduate"),
  master(8, "Master's Degree"), // Optional
  doctorate(9, "Doctorate");    // Optional

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
  male(1, "Male"),
  female(2, "Female"),
  other(3, "Other");

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
