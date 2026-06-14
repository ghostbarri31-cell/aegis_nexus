enum ExecutionStatus {
  classifying('Classifying'),
  routing('Routing'),
  executing('Executing'),
  completed('Completed'),
  failed('Failed');

  const ExecutionStatus(this.label);

  final String label;

  static ExecutionStatus fromValue(String value) {
    return ExecutionStatus.values.firstWhere(
      (s) => s.name == value || s.label == value,
      orElse: () => ExecutionStatus.completed,
    );
  }
}
