// lib/main_mindtrack.dart
import 'package:flutter/material.dart';
import 'daily_checkin.dart';

class MainMindTrackPage extends StatelessWidget {
  const MainMindTrackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f6fb),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Text(
              'MindTrack',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xff7b3df0),
              ),
            ),
            const SizedBox(height: 24),
            MindCard(
              title: 'Daily\nCheck-In',
              icon: Icons.calendar_today_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DailyCheckInPage()),
                );
              },
            ),
            const SizedBox(height: 16),
            MindCard(
              title: 'Journaling',
              icon: Icons.menu_book_rounded,
              onTap: () {
                // TODO: add journaling page later
              },
            ),
            const SizedBox(height: 16),
            MindCard(
              title: 'Progress\nVisualization',
              icon: Icons.bar_chart_rounded,
              onTap: () {
                // TODO: add progress page later
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MindCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const MindCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xff7b3df0), Color(0xff5fc3ff)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
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
