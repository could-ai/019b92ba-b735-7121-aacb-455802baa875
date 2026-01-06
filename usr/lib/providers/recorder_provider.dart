import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/recorded_event.dart';

class RecorderProvider with ChangeNotifier {
  final List<RecordedEvent> _events = [];
  bool _isRecording = false;
  bool _simulateDesktopEvents = false;
  Timer? _simulationTimer;
  final Uuid _uuid = const Uuid();

  List<RecordedEvent> get events => List.unmodifiable(_events);
  bool get isRecording => _isRecording;
  bool get simulateDesktopEvents => _simulateDesktopEvents;

  void toggleRecording() {
    _isRecording = !_isRecording;
    if (_isRecording) {
      _startSimulation();
    } else {
      _stopSimulation();
    }
    notifyListeners();
  }

  void toggleSimulation(bool value) {
    _simulateDesktopEvents = value;
    if (_isRecording) {
      _stopSimulation();
      _startSimulation();
    }
    notifyListeners();
  }

  void addEvent(EventType type, String description, {Offset? position}) {
    if (!_isRecording) return;

    final event = RecordedEvent(
      id: _uuid.v4(),
      timestamp: DateTime.now(),
      type: type,
      description: description,
      position: position,
    );
    
    _events.insert(0, event); // Add to top
    notifyListeners();
  }

  void clearEvents() {
    _events.clear();
    notifyListeners();
  }

  void _startSimulation() {
    _stopSimulation();
    if (!_simulateDesktopEvents) return;

    _simulationTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_isRecording) {
        timer.cancel();
        return;
      }
      
      // Simulate some desktop events that we can't easily capture in a sandboxed app
      final mockEvents = [
        (EventType.window, "Switched to window: 'Google Chrome'"),
        (EventType.system, "File created: 'report.docx'"),
        (EventType.keyboard, "Pressed: Ctrl + C"),
        (EventType.window, "Switched to window: 'VS Code'"),
        (EventType.click, "Right Click at (1024, 768)"),
      ];
      
      final randomEvent = (mockEvents..shuffle()).first;
      addEvent(randomEvent.$1, randomEvent.$2);
    });
  }

  void _stopSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = null;
  }
}
