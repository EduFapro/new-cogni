enum EducationLevel {
  incompleteElementary(1, "Incomplete Elementary"),
  completeElementary(2, "Complete Elementary"),
  incompleteHighSchool(3, "Incomplete High School"),
  completeHighSchool(4, "Complete High School"),
  incompleteCollege(5, "Incomplete College"),
  completeCollege(6, "Complete College"),
  postgraduate(7, "Postgraduate");

  final int numericValue;
  final String description;

  const EducationLevel(this.numericValue, this.description);

  static EducationLevel fromValue(int value) {
    return EducationLevel.values.firstWhere(
          (level) => level.numericValue == value,
      orElse: () => EducationLevel.completeElementary,
    );
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
      default:
        return Sex.other;
    }
  }
}

