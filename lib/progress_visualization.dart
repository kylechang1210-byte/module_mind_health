import 'package:flutter/material.dart';
import 'mood_distribution.dart';
import 'mood_trend.dart';

class ProgressVisualizationPage extends StatelessWidget {
  const ProgressVisualizationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7FB),
        elevation: 0,
        title: const Text(
          'Progress',
          style: TextStyle(
            color: Color(0xFF6D5DF6),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Removed search bar
              const Text(
                'Overview',
                style: TextStyle(
                  color: Color(0xFF6D5DF6),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Mood Trend Graph card
              _ProgressCard(
                title: 'Mood Trend Graph',
                subtitle: 'Your mood over time',
                gradientColors: const [Color(0xFF6D5DF6), Color(0xFF7BC5FF)],
                onView: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MoodTrendPage()),
                  );
                },
              ),

              const SizedBox(height: 12),

              // Mood Distribution Pie Chart card
              _ProgressCard(
                title: 'Mood Distribution Pie Chart',
                subtitle: 'Percentage of moods',
                gradientColors: const [Color(0xFFFA7AE5), Color(0xFFFFB5C2)],
                onView: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MoodDistributionPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final VoidCallback onView;

  const _ProgressCard({
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '“$subtitle”',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onView,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: gradientColors.last,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            child: const Text('View'),
          ),
        ],
      ),
    );
  }
}
