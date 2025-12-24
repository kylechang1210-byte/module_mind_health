import 'package:flutter/material.dart';
import 'database_mindtrack.dart';
import 'supabase_connection.dart';
import 'checkin_detail.dart';
import 'package:intl/intl.dart';

class CheckInHistoryPage extends StatefulWidget {
  const CheckInHistoryPage({super.key});

  @override
  State<CheckInHistoryPage> createState() => _CheckInHistoryPageState();
}

String formatSupabaseDate(String raw) {
  try {
    final dt = DateTime.parse(raw); // parses 2025-12-19 14:44:23.72651+00
    final local = dt.toLocal(); // convert from UTC to device timezone
    return DateFormat('yyyy-MM-dd').format(local); // or any pattern you want
  } catch (_) {
    return raw; // fallback
  }
}

class _CheckInHistoryPageState extends State<CheckInHistoryPage> {
  List<Map<String, dynamic>> items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  // ================== LOAD FROM SQLITE + SUPABASE ==================

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);

    try {
      // 1. Local SQLite
      final localRows = await DatabaseMindTrack.instance.getAllCheckIns();

      // 2. Remote Supabase (priority)
      List<Map<String, dynamic>> remote = [];
      try {
        final supabase = SupabaseConnection.client;
        final data = await supabase
            .from('checkins')
            .select()
            .order('date', ascending: false);

        remote = (data as List).map<Map<String, dynamic>>((row) => {
          'id': row['id'],
          'date': row['date'],
          'mood': int.tryParse('${row['mood']}') ?? 0,
          'score': row['score'] ?? 0,
          'feelings': row['feelings'] ?? '',
          'notes': row['notes'] ?? '',
        }).toList();
      } catch (_) {
        // Offline? Use local only
      }

      // 3. MERGE: Supabase wins, local fills gaps (NO DUPLICATES)
      final Map<String, Map<String, dynamic>> uniqueByDate = {};

      // Supabase FIRST (most authoritative)
      for (final row in remote) {
        final dateKey = formatSupabaseDate(row['date']);
        uniqueByDate[dateKey] = row;
      }

      // Local ONLY for dates NOT in Supabase
      for (final row in localRows) {
        final dateKey = DateFormat('yyyy-MM-dd').format(DateTime.parse(row['date']));
        if (!uniqueByDate.containsKey(dateKey)) {
          uniqueByDate[dateKey] = row;
        }
      }

      if (!mounted) return;
      setState(() {
        items = uniqueByDate.values.toList();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  Future<void> _deleteCheckIn(Map<String, dynamic> row) async {
    final int id = row['id'] as int;

    // Delete local
    try {
      await DatabaseMindTrack.instance.deleteCheckIn(id);
    } catch (_) {}

    // Delete remote (ignore errors if offline)
    try {
      final supabase = SupabaseConnection.client;
      await supabase.from('checkins').delete().eq('id', id);
    } catch (_) {}

    await _loadHistory();
  }

  void myAlertDialogDeleteCheckIn(
    BuildContext context,
    Map<String, dynamic> row,
  ) {
    AlertDialog deleteDialog = AlertDialog(
      title: const Text('Delete Check-In'),
      content: const Text('Are you sure you want to delete this entry?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            await _deleteCheckIn(row);
          },
          child: const Text('Delete'),
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return deleteDialog;
      },
    );
  }

  // ================== UI ==================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6D5DF6),
        elevation: 0,
        title: const Text(
          'Check-In History',
          style: TextStyle(
            color: Color(0xFFFFFFFF),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? const Center(child: Text('No check-ins yet'))
          : RefreshIndicator(
              onRefresh: _loadHistory,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final row = items[index];
                  return _buildCheckInCard(context, row);
                },
              ),
            ),
    );
  }

  Widget _buildCheckInCard(BuildContext context, Map<String, dynamic> row) {
    final rawDate = row['date'] ?? '';
    final displayDate = formatSupabaseDate(rawDate);
    final int score = row['score'] ?? 0;
    final String feelings = row['feelings'] ?? '';
    final int moodIndex = row['mood'] ?? 0;

    const moods = ['Terrible', 'Meh', 'Fine', 'Good', 'Great'];
    final moodText = (moodIndex >= 0 && moodIndex < moods.length)
        ? moods[moodIndex]
        : moodIndex.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF6D5DF6), Color(0xFF7BC5FF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date + mood + delete
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                displayDate,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
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
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    onPressed: () => myAlertDialogDeleteCheckIn(context, row),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),

          // feelings preview
          Text(
            feelings,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),


          // Detail button
          Align(
            alignment: Alignment.bottomRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CheckInDetailPage(data: row),
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                backgroundColor: Colors.white.withValues(alpha: 0.25),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Detail',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
