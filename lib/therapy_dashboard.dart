import 'package:flutter/material.dart';
import 'healing_music.dart';
import 'breathing.dart';
import 'movement.dart';
import 'therapy_admin.dart'; // Access to your admin tool

class TherapyDashboard extends StatelessWidget {
  const TherapyDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wellness Tools"),
        backgroundColor: const Color(0xFF5C9DFF),
        foregroundColor: Colors.white,
        actions: [
          // Optional: Button to reach therapy admin
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TherapyAdmin())),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildCard(
            context,
            "Healing Music",
            "Relax with calming sounds",
            Icons.music_note,
            Colors.purple,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HealingMusicPage())),
          ),
          _buildCard(
            context,
            "Breathing Exercise",
            "4-7-8 Breathing Technique",
            Icons.air,
            Colors.teal,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BreathingPage())),
          ),
          _buildCard(
            context,
            "Mindful Movement",
            "Yoga, Tai Chi, and more",
            Icons.directions_walk,
            Colors.orange,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MovementPage())),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}