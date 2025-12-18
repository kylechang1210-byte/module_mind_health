import 'package:flutter/material.dart';

class CheckInDetailPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const CheckInDetailPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final date = data['date'] ?? '';
    final mood = data['mood'] ?? 0;
    final score = data['score'] ?? 0;
    final feelings = data['feelings'] ?? '';
    final notes = data['notes'] ?? '';

    // simple mapping from mood int to text
    const moods = ['Terrible','Meh','Fine','Good','Great'];
    final moodText = (mood >= 0 && mood < moods.length)
        ? moods[mood]
        : mood.toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-In Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              date,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text('Mood: $moodText ($score%)'),
            const SizedBox(height: 12),
            Text('Feelings: $feelings'),
            const SizedBox(height: 12),
            Text(
              'Notes:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              notes.isEmpty ? 'No notes' : notes,
            ),
          ],
        ),
      ),
    );
  }
}
