class RoutingInfo {
  const RoutingInfo({
    required this.taskType,
    required this.selectedProvider,
    required this.executionStatus,
    this.confidence,
  });

  final String taskType;
  final String selectedProvider;
  final String executionStatus;
  final double? confidence;

  Map<String, dynamic> toJson() => {
        'taskType': taskType,
        'selectedProvider': selectedProvider,
        'executionStatus': executionStatus,
        if (confidence != null) 'confidence': confidence,
      };

  factory RoutingInfo.fromJson(Map<String, dynamic> json) {
    return RoutingInfo(
      taskType: json['taskType'] as String? ?? 'Text',
      selectedProvider: json['selectedProvider'] as String? ?? '—',
      executionStatus: json['executionStatus'] as String? ?? 'Completed',
      confidence: (json['confidence'] as num?)?.toDouble(),
    );
  }

  RoutingInfo copyWith({
    String? taskType,
    String? selectedProvider,
    String? executionStatus,
    double? confidence,
  }) {
    return RoutingInfo(
      taskType: taskType ?? this.taskType,
      selectedProvider: selectedProvider ?? this.selectedProvider,
      executionStatus: executionStatus ?? this.executionStatus,
      confidence: confidence ?? this.confidence,
    );
  }
}
