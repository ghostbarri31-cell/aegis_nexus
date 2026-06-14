enum TaskType {
  text('text'),
  code('code'),
  image('image'),
  video('video'),
  research('research');

  const TaskType(this.value);

  final String value;

  static TaskType fromValue(String value) {
    return TaskType.values.firstWhere(
      (t) => t.value == value,
      orElse: () => TaskType.text,
    );
  }

  String get displayLabel {
    switch (this) {
      case TaskType.text:
        return 'Text';
      case TaskType.code:
        return 'Code';
      case TaskType.image:
        return 'Image';
      case TaskType.video:
        return 'Video';
      case TaskType.research:
        return 'Research';
    }
  }
}
