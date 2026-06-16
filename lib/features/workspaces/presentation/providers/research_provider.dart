import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/research_session.dart';

/// Provider for managing Research workspace state.
/// 
/// Handles research sessions, sources, findings, and report generation.
/// Future: Integration with web search APIs, citation management,
/// and automated report generation.
class ResearchProvider with ChangeNotifier {
  final List<ResearchSession> _sessions = [];
  ResearchSession? _selectedSession;
  bool _isLoading = false;

  List<ResearchSession> get sessions => _sessions;
  ResearchSession? get selectedSession => _selectedSession;
  bool get isLoading => _isLoading;

  /// Create a new research session.
  ResearchSession createSession({
    required String title,
    required String query,
  }) {
    final session = ResearchSession(
      id: const Uuid().v4(),
      title: title,
      query: query,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _sessions.add(session);
    _selectedSession = session;
    notifyListeners();
    return session;
  }

  /// Select a research session.
  void selectSession(String sessionId) {
    _selectedSession = _sessions.firstWhere(
      (s) => s.id == sessionId,
      orElse: () => _sessions.first,
    );
    notifyListeners();
  }

  /// Delete a research session.
  void deleteSession(String sessionId) {
    _sessions.removeWhere((s) => s.id == sessionId);
    if (_selectedSession?.id == sessionId) {
      _selectedSession = _sessions.isNotEmpty ? _sessions.first : null;
    }
    notifyListeners();
  }

  /// Add a source to the selected session.
  void addSource(ResearchSource source) {
    if (_selectedSession == null) return;
    
    final updated = _selectedSession!.copyWith(
      sources: [..._selectedSession!.sources, source],
      updatedAt: DateTime.now(),
    );
    
    _updateSession(updated);
  }

  /// Add a finding to the selected session.
  void addFinding(ResearchFinding finding) {
    if (_selectedSession == null) return;
    
    final updated = _selectedSession!.copyWith(
      findings: [..._selectedSession!.findings, finding],
      updatedAt: DateTime.now(),
    );
    
    _updateSession(updated);
  }

  /// Generate a report for the selected session.
  /// 
  /// Future: AI-powered report generation with customizable templates.
  void generateReport() {
    if (_selectedSession == null) return;
    
    final report = GeneratedReport(
      id: const Uuid().v4(),
      title: 'Report: ${_selectedSession!.title}',
      content: 'Generated report content...',
      generatedAt: DateTime.now(),
    );
    
    final updated = _selectedSession!.copyWith(
      report: report,
      status: ResearchStatus.completed,
      updatedAt: DateTime.now(),
    );
    
    _updateSession(updated);
  }

  /// Update session status.
  void updateSessionStatus(ResearchStatus status) {
    if (_selectedSession == null) return;
    
    final updated = _selectedSession!.copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );
    
    _updateSession(updated);
  }

  void _updateSession(ResearchSession updated) {
    final index = _sessions.indexWhere((s) => s.id == updated.id);
    if (index != -1) {
      _sessions[index] = updated;
      _selectedSession = updated;
      notifyListeners();
    }
  }
}
