import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/recorder_provider.dart';
import '../models/recorded_event.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RecorderProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Desktop Behavior Recorder'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: provider.events.isEmpty ? null : provider.clearEvents,
                tooltip: 'Clear Logs',
              ),
            ],
          ),
          body: Column(
            children: [
              _buildControlPanel(context, provider),
              const Divider(height: 1),
              Expanded(
                child: _buildEventCaptureZone(context, provider),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: provider.toggleRecording,
            backgroundColor: provider.isRecording ? Colors.red : Colors.green,
            icon: Icon(provider.isRecording ? Icons.stop : Icons.fiber_manual_record),
            label: Text(provider.isRecording ? 'STOP RECORDING' : 'START RECORDING'),
          ),
        );
      },
    );
  }

  Widget _buildControlPanel(BuildContext context, RecorderProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  "Interactions within this app are recorded automatically. Enable simulation to see mock external desktop events.",
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Status: ${provider.isRecording ? "RECORDING" : "IDLE"}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: provider.isRecording ? Colors.red : Colors.grey,
                ),
              ),
              Row(
                children: [
                  const Text("Simulate External Events"),
                  Switch(
                    value: provider.simulateDesktopEvents,
                    onChanged: provider.toggleSimulation,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventCaptureZone(BuildContext context, RecorderProvider provider) {
    // We wrap the list in a listener to capture events happening on the list itself
    return Listener(
      onPointerDown: (event) {
        provider.addEvent(
          EventType.click,
          "Mouse Down (Button 1)",
          position: event.position,
        );
      },
      onPointerMove: (event) {
        // Throttling could be added here, but for demo we just log occasionally or ignore to avoid spam
        // provider.addEvent(EventType.mouseMove, "Mouse Move", position: event.position);
      },
      child: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          // Simple key logging
          if (event.runtimeType.toString() == 'KeyDownEvent') { // Check specifically for down to avoid duplicates
             provider.addEvent(
              EventType.keyboard,
              "Key Pressed: ${event.logicalKey.keyLabel}",
            );
          }
          return KeyEventResult.ignored;
        },
        child: Container(
          color: Colors.transparent, // Ensure hits are captured
          child: provider.events.isEmpty
              ? const Center(
                  child: Text(
                    'No events recorded.\nPress Start to begin.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: provider.events.length,
                  itemBuilder: (context, index) {
                    final event = provider.events[index];
                    return _buildEventTile(context, event);
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildEventTile(BuildContext context, RecordedEvent event) {
    IconData icon;
    Color color;

    switch (event.type) {
      case EventType.click:
        icon = Icons.mouse;
        color = Colors.blue;
        break;
      case EventType.keyboard:
        icon = Icons.keyboard;
        color = Colors.orange;
        break;
      case EventType.mouseMove:
        icon = Icons.ads_click;
        color = Colors.lightBlue;
        break;
      case EventType.window:
        icon = Icons.window;
        color = Colors.purple;
        break;
      case EventType.system:
        icon = Icons.settings_system_daydream;
        color = Colors.grey;
        break;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(event.description),
      subtitle: Text(
        event.position != null
            ? 'Pos: (${event.position!.dx.toStringAsFixed(0)}, ${event.position!.dy.toStringAsFixed(0)})'
            : 'System Event',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Text(
        DateFormat('HH:mm:ss').format(event.timestamp),
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
      dense: true,
    );
  }
}
