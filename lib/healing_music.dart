import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'therapy_model.dart';
import 'database_mindtrack.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HealingMusicPage extends StatefulWidget {
  const HealingMusicPage({super.key});
  @override
  State<HealingMusicPage> createState() => _HealingMusicPageState();
}

class _HealingMusicPageState extends State<HealingMusicPage> {
  int _playingId = -1;
  final Color _mainColor = const Color(0xFF7555FF);
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _toggleMusic(int id, String path, String title) async {
    debugPrint("Attempting to play: $path");
    try {
      if (_playingId == id) {
        await _audioPlayer.stop();
        setState(() => _playingId = -1);
      } else {
        await _audioPlayer.stop();
        // Remove 'assets/' if present
        String cleanPath = path.startsWith('assets/')
            ? path.replaceFirst('assets/', '')
            : path;
        await _audioPlayer.play(AssetSource(cleanPath));
        setState(() => _playingId = id);

        // Record History
        DatabaseMindTrack.instance.recordHistory('Music', title);
        Provider.of<TherapyModel>(
          context,
          listen: false,
        ).recordSession('Music: $title');
      }
    } catch (e) {
      debugPrint("AUDIO ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f6fb),
      appBar: AppBar(
        title: const Text(
          'Healing Music',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_mainColor, const Color(0xff5fc3ff)],
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
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _mainColor,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                // OLD: future: DatabaseMindTrack.instance.getAllMusic(),
                // NEW: Fetch from Supabase
                future: Supabase.instance.client.from('music').select().order('id'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty){
                    return const Center(child: Text("No music available yet."));
                  }
                  // ... rest of the builder stays the same ...
                  final songs = List<Map<String, dynamic>>.from(snapshot.data!); // Ensure type
                  return ListView.builder(
                      itemCount: songs.length,
                      itemBuilder: (context, index) {
                        // Map snake_case (Supabase) to the keys your widget expects
                        final song = songs[index];
                        final mappedSong = {
                          'id': song['id'],
                          'title': song['title'],
                          'description': song['description'],
                          'iconCode': song['icon_code'] ?? 0xe6bd,
                          'audioPath': song['audio_path']
                        };
                        return _buildMusicCard(mappedSong);
                      }
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
    IconData icon = IconData(song['iconCode'], fontFamily: 'MaterialIcons');
    bool isPlaying = _playingId == id;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: isPlaying ? Border.all(color: _mainColor, width: 3) : null,
        boxShadow: [
          BoxShadow(
            color: _mainColor.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
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
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(isPlaying ? Icons.stop_circle : Icons.play_circle_fill),
            color: isPlaying ? Colors.grey : _mainColor,
            iconSize: 32,
            onPressed: () => _toggleMusic(id, song['audioPath'], title),
          ),
        ],
      ),
    );
  }
}
