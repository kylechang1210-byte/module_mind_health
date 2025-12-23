import 'package:flutter/material.dart';

class TherapySession {
  String toolName;
  DateTime timestamp;
  TherapySession({required this.toolName, required this.timestamp});
}

class TherapyModel extends ChangeNotifier {
  final List<TherapySession> _history = [];
  List<TherapySession> get history => _history;

  void recordSession(String name) {
    _history.add(TherapySession(toolName: name, timestamp: DateTime.now()));
    notifyListeners();
  }
}