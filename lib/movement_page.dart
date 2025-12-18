import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'therapy_model.dart';

class MovementPage extends StatefulWidget {
  const MovementPage({super.key});

  @override
  State<MovementPage> createState() => _MovementPageState();
}

class _MovementPageState extends State<MovementPage> {
  // --- Data: List of Stretches ---
  final List<Map<String, dynamic>> _stretches = [
    {
      "title": "Neck Roll",
      "desc": "Gently roll your head in a circle. 3 times each direction.",
      "icon": Icons.face,
    },
    {
      "title": "Shoulder Shrug",
      "desc": "Lift your shoulders up to your ears, hold for 3s, then drop.",
      "icon": Icons.accessibility_new,
    },
    {
      "title": "Sky Reach",
      "desc": "Interlock fingers and push your palms up towards the ceiling.",
      "icon": Icons.pan_tool,
    },
  ];

  int _currentStep = 0;
  bool _isCompleted = false;

  // Colors
  final Color _purple = const Color(0xff7b3df0);
  final Color _blue = const Color(0xff5fc3ff);

  void _nextStep() {
    setState(() {
      if (_currentStep < _stretches.length - 1) {
        _currentStep++;
      } else {
        _isCompleted = true;
        // Save to History
        Provider.of<TherapyModel>(context, listen: false).recordSession('Movement Session');
      }
    });
  }

  void _reset() {
    setState(() {
      _currentStep = 0;
      _isCompleted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f6fb),
      appBar: AppBar(
        title: const Text('Mindful Movement', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [_purple, _blue]),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _isCompleted ? _buildCompletionScreen() : _buildStepScreen(),
      ),
    );
  }

  // --- Screen 1: The Active Step ---
  Widget _buildStepScreen() {
    final step = _stretches[_currentStep];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Progress Indicator
        Text(
          "Step ${_currentStep + 1} of ${_stretches.length}",
          style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 30),

        // Large Card for the Stretch
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: _purple.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // Icon Circle
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [_purple.withOpacity(0.2), _blue.withOpacity(0.2)]),
                ),
                child: Icon(step['icon'], size: 80, color: _purple),
              ),
              const SizedBox(height: 20),
              // Title
              Text(
                step['title'],
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _purple,
                ),
              ),
              const SizedBox(height: 15),
              // Description
              Text(
                step['desc'],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.black87),
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // "Next" Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              backgroundColor: Colors.transparent, // Transparent to show gradient
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: _nextStep,
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [_purple, _blue]),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Container(
                alignment: Alignment.center,
                constraints: const BoxConstraints(minHeight: 50),
                child: const Text(
                  "NEXT STRETCH",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- Screen 2: Completion ---
  Widget _buildCompletionScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 100, color: Colors.green),
          const SizedBox(height: 20),
          Text(
            "Session Complete!",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _purple),
          ),
          const SizedBox(height: 10),
          const Text("Great job taking care of your body.", style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 40),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: () {
              Navigator.pop(context); // Go back to Dashboard
            },
            child: const Text("FINISH", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: _reset,
            child: const Text("Do it again"),
          )
        ],
      ),
    );
  }
}