import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatCheckInDate(String raw) {
  try {
    final dt = DateTime.parse(raw);
    final local = dt.toLocal();
    return DateFormat('yyyy-MM-dd').format(local);
  } catch (_) {
    return raw;
  }
}

class CheckInDetailPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const CheckInDetailPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final String rawDate = data['date'] ?? '';
    final String date = formatCheckInDate(rawDate);

    final int mood = data['mood'] ?? 0;
    final int score = data['score'] ?? 0;
    final String feelings = data['feelings'] ?? '';
    final String notes = data['notes'] ?? '';

    const moods = ['Terrible', 'Meh', 'Fine', 'Good', 'Great'];
    final String moodText = (mood >= 0 && mood < moods.length)
        ? moods[mood]
        : mood.toString();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6D5DF6),
        elevation: 0,
        title: const Text(
          'Check-In Detail',
          style: TextStyle(
            color: Color(0xFFF4F7FB),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Top card with gradient, similar to your history modules
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6D5DF6), Color(0xFF7BC5FF)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date + mood + score
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          date,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$moodText  •  $score%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Feelings
                    Text(
                      feelings.isEmpty ? 'No feelings recorded' : feelings,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Notes section like other modules (white card)
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6D5DF6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            notes.isEmpty
                                ? 'No notes for this check-in.'
                                : notes,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
