import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'therapy_model.dart';
import 'database_mindtrack.dart';
import 'package:audioplayers/audioplayers.dart';

class HealingMusicPage extends StatefulWidget {
  const HealingMusicPage({super.key});

  @override
  State<HealingMusicPage> createState() => _HealingMusicPageState();
}

class _HealingMusicPageState extends State<HealingMusicPage> {
  // Logic to track which song is playing using ID
  int _playingId = -1;
  final Color _mainColor = const Color(0xFF7555FF);
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  // Function to handle the music logic
  void _toggleMusic(int id, String path) async {
    print("Attempting to play: $path");

    try {
      if (_playingId == id) {
        await _audioPlayer.stop();
        setState(() => _playingId = -1);
      } else {
        await _audioPlayer.stop();

        // Remove 'assets/' prefix for AssetSource
        String cleanPath = path.replaceFirst('assets/', '');

        // This is the correct way for audioplayers 6.x
        await _audioPlayer.play(AssetSource(cleanPath));

        setState(() => _playingId = id);
      }
    } catch (e) {
      print("AUDIO ERROR: $e");
      // This will pop up a message if the file is missing
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

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

            // Replaced ListView with FutureBuilder to read from DB
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: DatabaseMindTrack.instance.getAllMusic(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No music found in database."));
                  }

                  final songs = snapshot.data!;

                  return ListView.builder(
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      return _buildMusicCard(songs[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMusicCard(Map<String, dynamic> song) {
    int id = song['id'];
    String title = song['title'];
    String subtitle = song['description'];

    // Convert integer code back to IconData
    IconData icon = IconData(song['iconCode'], fontFamily: 'MaterialIcons');

    bool isPlaying = _playingId == id;

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
                icon: Icon(isPlaying ? Icons.stop_circle : Icons.play_circle_fill), // Changed icon to show stop when playing
                color: isPlaying ? Colors.grey : _mainColor,
                iconSize: 32,
                onPressed: () {
                  _toggleMusic(id, song['audioPath']);
                  Provider.of<TherapyModel>(context, listen: false).recordSession('Music: $title');
                },
              ),
              // Pause Button
              IconButton(
                icon: const Icon(Icons.pause_circle_filled),
                color: isPlaying ? _mainColor : Colors.grey[300],
                iconSize: 32,
                onPressed: () {
                  setState(() => _playingId = -1);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}