import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'therapy_model.dart';

class HealingMusicPage extends StatefulWidget {
  const HealingMusicPage({super.key});

  @override
  State<HealingMusicPage> createState() => _HealingMusicPageState();
}

class _HealingMusicPageState extends State<HealingMusicPage> {
  // Logic to track which song is playing
  int _playingIndex = -1;
  final Color _mainColor = const Color(0xFF7555FF);

  final List<Map<String, dynamic>> _songs = [
    {"title": "Rainy Mood", "desc": "Calming rain sounds", "icon": Icons.water_drop},
    {"title": "Forest Walk", "desc": "Birds and nature", "icon": Icons.forest},
    {"title": "Deep Focus", "desc": "White noise for study", "icon": Icons.headphones},
    {"title": "Ocean Waves", "desc": "Gentle beach tides", "icon": Icons.waves},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f6fb),
      appBar: AppBar(
        title: const Text('Healing Music', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_mainColor, const Color(0xff5fc3ff)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              "Select a Sound",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _mainColor),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _songs.length,
                itemBuilder: (context, index) {
                  return _buildMusicCard(index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMusicCard(int index) {
    bool isPlaying = _playingIndex == index;
    String title = _songs[index]['title'];
    String subtitle = _songs[index]['desc'];
    IconData icon = _songs[index]['icon'];

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        // Add a border if playing, otherwise keep it clean
        border: isPlaying ? Border.all(color: _mainColor, width: 3) : null,
        boxShadow: [
          BoxShadow(
            color: _mainColor.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0,5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: isPlaying
                    ? [_mainColor, const Color(0xff5fc3ff)]
                    : [Colors.grey.shade300, Colors.grey.shade400],
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 15),

          // Text Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isPlaying ? _mainColor : const Color(0xff333333),
                  ),
                ),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Play Button
              IconButton(
                icon: const Icon(Icons.play_circle_fill),
                color: isPlaying ? Colors.grey : _mainColor,
                iconSize: 32,
                onPressed: () {
                  setState(() => _playingIndex = index);
                  Provider.of<TherapyModel>(context, listen: false).recordSession('Music: $title');
                },
              ),
              // Pause Button
              IconButton(
                icon: const Icon(Icons.pause_circle_filled),
                color: isPlaying ? _mainColor : Colors.grey[300],
                iconSize: 32,
                onPressed: () {
                  setState(() => _playingIndex = -1);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}