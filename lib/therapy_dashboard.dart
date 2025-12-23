import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'therapy_model.dart';
import 'healing_music.dart';
import 'breathing.dart';
import 'movement.dart';
import 'therapy_history.dart';

class TherapyDashboard extends StatelessWidget {
  const TherapyDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TherapyModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MindTrack Therapy',
        theme: ThemeData(primarySwatch: Colors.deepPurple, useMaterial3: true),
        initialRoute: '/',
        routes: {
          '/': (context) => const TherapyPage(),
          '/healing_music': (context) => const HealingMusicPage(),
          '/breathing': (context) => const BreathingPage(),
          '/movement': (context) => const MovementPage(),
          '/therapy_history': (context) => const TherapyHistory(),
          //'/admin': (context) => const TherapyAdmin(),
        },
      ),
    );
  }
}

class TherapyPage extends StatelessWidget {
  const TherapyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f6fb),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              const Text(
                'Therapy',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff7b3df0),
                ),
              ),
              const SizedBox(height: 24),

              // Tool 1: Music
              _buildTherapyCard(
                context: context,
                title: 'Healing\nMusic',
                icon: Icons.music_note_rounded,
                onTap: () => Navigator.pushNamed(context, '/healing_music'),
              ),
              const SizedBox(height: 16),

              // Tool 2: Breathing
              _buildTherapyCard(
                context: context,
                title: 'Breathing\nExercise',
                icon: Icons.air_rounded,
                onTap: () => Navigator.pushNamed(context, '/breathing'),
              ),
              const SizedBox(height: 16),

              // Tool 3: Movement
              _buildTherapyCard(
                context: context,
                title: 'Mindful\nMovement',
                icon: Icons.accessibility_new_rounded,
                onTap: () => Navigator.pushNamed(context, '/movement'),
              ),
              const SizedBox(height: 16),

              // History
              _buildTherapyCard(
                context: context,
                title: 'Therapy History',
                icon: Icons.history,
                onTap: () => Navigator.pushNamed(context, '/therapy_history'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTherapyCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          // Updated gradient to match MainMindTrackPage colors
          gradient: const LinearGradient(
            colors: [Color(0xff7b3df0), Color(0xff5fc3ff)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff7b3df0).withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(icon, size: 48, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
