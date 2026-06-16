import 'package:equatable/equatable.dart';

/// Research session model for the Research workspace.
/// 
/// Represents a dedicated research investigation with sources,
/// findings, and generated reports.
class ResearchSession extends Equatable {
  const ResearchSession({
    required this.id,
    required this.title,
    required this.query,
    required this.createdAt,
    required this.updatedAt,
    this.status = ResearchStatus.active,
    this.sources = const [],
    this.findings = const [],
    this.report,
  });

  final String id;
  final String title;
  final String query;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ResearchStatus status;
  final List<ResearchSource> sources;
  final List<ResearchFinding> findings;
  final GeneratedReport? report;

  ResearchSession copyWith({
    String? id,
    String? title,
    String? query,
    DateTime? createdAt,
    DateTime? updatedAt,
    ResearchStatus? status,
    List<ResearchSource>? sources,
    List<ResearchFinding>? findings,
    GeneratedReport? report,
  }) {
    return ResearchSession(
      id: id ?? this.id,
      title: title ?? this.title,
      query: query ?? this.query,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      sources: sources ?? this.sources,
      findings: findings ?? this.findings,
      report: report ?? this.report,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        query,
        createdAt,
        updatedAt,
        status,
        sources,
        findings,
        report,
      ];
}

/// Status of a research session.
enum ResearchStatus {
  active,
  completed,
  archived,
}

/// Source referenced in research.
/// 
/// Future: Web search integration, citation management,
/// source verification, and automatic source tracking.
class ResearchSource extends Equatable {
  const ResearchSource({
    required this.id,
    required this.title,
    required this.url,
    required this.type,
    this.citation,
    this.relevanceScore,
  });

  final String id;
  final String title;
  final String url;
  final SourceType type;
  final String? citation;
  final double? relevanceScore;

  @override
  List<Object?> get props => [id, title, url, type, citation, relevanceScore];
}

/// Type of research source.
enum SourceType {
  web,
  academic,
  document,
  database,
  custom,
}

/// Finding from research analysis.
class ResearchFinding extends Equatable {
  const ResearchFinding({
    required this.id,
    required this.content,
    required this.timestamp,
    this.sourceIds = const [],
    this.confidence,
  });

  final String id;
  final String content;
  final DateTime timestamp;
  final List<String> sourceIds;
  final double? confidence;

  @override
  List<Object?> get props => [id, content, timestamp, sourceIds, confidence];
}

/// Generated research report.
/// 
/// Future: Report templates, export formats (PDF, Markdown),
// collaborative editing, and version history.
class GeneratedReport extends Equatable {
  const GeneratedReport({
    required this.id,
    required this.title,
    required this.content,
    required this.generatedAt,
    this.format = ReportFormat.markdown,
  });

  final String id;
  final String title;
  final String content;
  final DateTime generatedAt;
  final ReportFormat format;

  @override
  List<Object?> get props => [id, title, content, generatedAt, format];
}

/// Report format for export.
enum ReportFormat {
  markdown,
  pdf,
  html,
  plainText,
}
