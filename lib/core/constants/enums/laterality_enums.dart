enum Laterality {
  rightHanded(1, "Destro"),
  leftHanded(2, "Canhoto"),
  ambidextrous(3, "Ambidestro");

  final int numericValue;
  final String description;

  const Laterality(this.numericValue, this.description);

  static Laterality fromValue(int value) {
    return Laterality.values.firstWhere(
      (l) => l.numericValue == value,
      orElse: () => Laterality.rightHanded,
    );
  }

  static Laterality fromLabel(String label) {
    switch (label.toLowerCase()) {
      case 'destro':
        return Laterality.rightHanded;
      case 'canhoto':
        return Laterality.leftHanded;
      case 'ambidestro':
        return Laterality.ambidextrous;
      default:
        return Laterality.rightHanded;
    }
  }

  String get label {
    switch (this) {
      case Laterality.rightHanded:
        return 'Destro';
      case Laterality.leftHanded:
        return 'Canhoto';
      case Laterality.ambidextrous:
        return 'Ambidestro';
    }
  }
}
