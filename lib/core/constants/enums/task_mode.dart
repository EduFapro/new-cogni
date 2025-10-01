enum TaskMode {
  play(0, "Play"),
  record(1, "Record");

  final int numericValue;
  final String description;

  const TaskMode(this.numericValue, this.description);

  static TaskMode fromValue(int value) {
    return TaskMode.values.firstWhere(
          (mode) => mode.numericValue == value,
      orElse: () => TaskMode.play,
    );
  }
}
