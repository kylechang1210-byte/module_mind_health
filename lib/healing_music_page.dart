import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'therapy_model.dart';

class HealingMusicPage extends StatelessWidget {
  const HealingMusicPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f6fb), // Matching Main Page Background
      appBar: AppBar(
        title: const Text('Healing Music', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff7b3df0), Color(0xff5fc3ff)], // Matching Gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select a Sound",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xff7b3df0), // Matching Title Color
              ),
            ),
            const SizedBox(height: 20),

            // --- Track 1 ---
            _buildMusicCard(context, "Rainy Mood", "Calming rain sounds", Icons.water_drop),
            const SizedBox(height: 15),

            // --- Track 2 ---
            _buildMusicCard(context, "Forest Walk", "Birds and nature", Icons.forest),
            const SizedBox(height: 15),

            // --- Track 3 ---
            _buildMusicCard(context, "Deep Focus", "White noise for study", Icons.headphones),
          ],
        ),
      ),
    );
  }

  // Helper widget to create cards that look like your Main Page
  Widget _buildMusicCard(BuildContext context, String title, String subtitle, IconData icon) {
    return GestureDetector(
      onTap: () {
        // Logic: Record the session
        Provider.of<TherapyModel>(context, listen: false).recordSession('Music: $title');

        // Visual Feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Now Playing: $title')),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff7b3df0).withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Container with Gradient
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xff7b3df0), Color(0xff5fc3ff)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 20),
            // Text Info
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff333333),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.play_circle_fill, color: Color(0xff7b3df0), size: 30),
          ],
        ),
      ),
    );
  }
}