import 'package:flutter/material.dart';

// The Model: Defines the data structure
class TherapySession {
  String toolName;
  DateTime timestamp;

  TherapySession({required this.toolName, required this.timestamp});
}

// The ViewModel: Manages state and logic
class TherapyModel extends ChangeNotifier {
  // Private state
  final List<TherapySession> _history = [];

  // Getter for the UI to access data
  List<TherapySession> get history => _history;

  // Logic to update state
  void recordSession(String name) {
    _history.add(TherapySession(toolName: name, timestamp: DateTime.now()));
    // Notify all listeners to rebuild
    notifyListeners();
  }
}
