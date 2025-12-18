import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'therapy_model.dart';

class BreathingPage extends StatefulWidget {
  const BreathingPage({super.key});

  @override
  State<BreathingPage> createState() => _BreathingPageState();
}

class _BreathingPageState extends State<BreathingPage> {
  // --- Timer Logic ---
  Timer? _timer;
  int _counter = 4;
  String _phase = "Ready";
  bool _isRunning = false;
  bool _isPaused = false;

  // 🎨 Color Consistency: #7555FF
  final Color _brandColor = const Color(0xFF7555FF);

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
      if (_phase == "Ready") {
        _phase = "Inhale";
        _counter = 4;
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused) return;

      setState(() {
        if (_counter > 1) {
          _counter--;
        } else {
          // Switch Phases
          if (_phase == "Inhale") {
            _phase = "Hold";
            _counter = 4;
          } else if (_phase == "Hold") {
            _phase = "Exhale";
            _counter = 4;
          } else if (_phase == "Exhale") {
            _phase = "Inhale";
            _counter = 4;
          }
        }
      });
    });
  }

  void _pauseTimer() {
    setState(() {
      _isPaused = true;
      _timer?.cancel();
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _phase = "Ready";
      _counter = 4;
    });
    // Log session
    Provider.of<TherapyModel>(context, listen: false).recordSession('Breathing Session');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f6fb),
      appBar: AppBar(
        title: const Text('Breathing Exercise', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_brandColor, const Color(0xff5fc3ff)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        // Ensures vertical centering for the whole page content
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Vertical Center
            crossAxisAlignment: CrossAxisAlignment.center, // Horizontal Center
            children: [
              // --- 1. The Breathing Circle ---
              Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [_brandColor, const Color(0xff5fc3ff)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _brandColor.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _phase,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "$_counter",
                      style: const TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),

              // --- 2. Control Buttons ---
              // Main Action Button (Start/Pause/Resume)
              SizedBox(
                width: 200, // Make button bigger
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandColor, // Requested Color #7555FF
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22), // Requested Radius
                    ),
                    elevation: 5,
                  ),
                  onPressed: () {
                    if (_isRunning && !_isPaused) {
                      _pauseTimer();
                    } else {
                      _startTimer();
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isRunning && !_isPaused ? Icons.pause : Icons.play_arrow,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _isRunning && !_isPaused
                            ? "PAUSE"
                            : (_isPaused ? "RESUME" : "START"),
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Reset Button (Only visible if running)
              if (_isRunning || _isPaused)
                SizedBox(
                  width: 200, // Matching width
                  height: 55,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _brandColor,
                      side: BorderSide(color: _brandColor, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22), // Requested Radius
                      ),
                    ),
                    onPressed: _resetTimer,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh),
                        SizedBox(width: 8),
                        Text("RESET", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}