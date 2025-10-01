enum ProgressStatus {
  pending(1, "Pending"),
  inProgress(2, "In Progress"),
  completed(3, "Completed");

  final int numericValue;
  final String description;

  const ProgressStatus(this.numericValue, this.description);

  static ProgressStatus fromValue(int value) {
    return ProgressStatus.values.firstWhere(
          (s) => s.numericValue == value,
      orElse: () => ProgressStatus.pending,
    );
  }
}

/// Type aliases for semantic clarity
typedef EvaluationStatus = ProgressStatus;
typedef ModuleStatus = ProgressStatus;
typedef TaskStatus = ProgressStatus;