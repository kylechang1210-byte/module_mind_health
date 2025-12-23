import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_mindtrack.dart';
import 'journal_detail.dart';
import 'supabase_connection.dart';

// date helper (or import from a shared file)
String formatJournalDate(String raw) {
  try {
    final dt = DateTime.parse(raw);
    final local = dt.toLocal();
    return DateFormat('yyyy-MM-dd').format(local);
  } catch (_) {
    return raw;
  }
}

class JournalHistoryPage extends StatefulWidget {
  const JournalHistoryPage({super.key});

  @override
  State<JournalHistoryPage> createState() => _JournalHistoryPageState();
}

class _JournalHistoryPageState extends State<JournalHistoryPage> {
  List<Map<String, dynamic>> _journals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJournals();
  }

  Future<void> _loadJournals() async {
    setState(() => _isLoading = true);

    try {
      // 1) Local SQLite
      final localRows = await DatabaseMindTrack.instance.getAllJournals();
      final local = localRows
          .map((row) => {...row, 'source': 'local'})
          .toList();

      // 2) Remote Supabase
      List<Map<String, dynamic>> remote = [];
      try {
        final supabase = SupabaseConnection.client;
        final data = await supabase
            .from('journals')
            .select()
            .order('date', ascending: false);

        remote = (data as List)
            .map<Map<String, dynamic>>(
              (row) => {
                'id': row['id'],
                'date': row['date'],
                'title': row['title'] ?? '',
                'mood': row['mood'] ?? '',
                'content': row['content'] ?? '',
                'source': 'supabase',
              },
            )
            .toList();
      } catch (_) {
        // if remote fails (offline), just keep local
      }

      // 3) Merge + de‑duplicate by id, prefer Supabase over local
      final Map<String, Map<String, dynamic>> uniqueById = {};

      for (final row in local) {
        final idKey = '${row['id']}';
        uniqueById[idKey] = row; // local baseline
      }

      for (final row in remote) {
        final idKey = '${row['id']}';
        // if remote exists, overwrite local
        uniqueById[idKey] = row;
      }

      final merged = uniqueById.values.toList()
        ..sort((a, b) {
          // optional: sort by date desc after merge
          final ad = (a['date'] ?? '').toString();
          final bd = (b['date'] ?? '').toString();
          return bd.compareTo(ad);
        });

      if (!mounted) return;
      setState(() => _journals = merged);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load journals: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteJournal(Map<String, dynamic> row) async {
    final int id = row['id'] as int;

    // local
    try {
      await DatabaseMindTrack.instance.deleteJournal(id);
    } catch (_) {}

    // remote
    try {
      final supabase = SupabaseConnection.client;
      await supabase.from('journals').delete().eq('id', id);
    } catch (_) {}

    await _loadJournals();
  }

  void myAlertDialogDeleteJournal(
    BuildContext context,
    Map<String, dynamic> row,
  ) {
    AlertDialog deleteDialog = AlertDialog(
      title: const Text('Delete Journal'),
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
            await _deleteJournal(row);
          },
          child: const Text('Delete'),
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) => deleteDialog,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7FB),
        elevation: 0,
        title: const Text(
          'Journal History',
          style: TextStyle(
            color: Color(0xFF6D5DF6),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _journals.isEmpty
          ? const Center(child: Text('No journal entries yet.'))
          : RefreshIndicator(
              onRefresh: _loadJournals,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: _journals.length,
                itemBuilder: (context, index) {
                  final data = _journals[index];
                  return _buildJournalCard(context, data);
                },
              ),
            ),
    );
  }

  Widget _buildJournalCard(BuildContext context, Map<String, dynamic> data) {
    final String rawDate = data['date'] ?? '';
    final String date = formatJournalDate(rawDate);

    final String title = data['title'] ?? '';
    final String mood = data['mood'] ?? '';
    final String source = data['source'] as String? ?? 'local';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF6D5DF6), Color(0xFFFA7AE5)],
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
                date,
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
                      mood,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    onPressed: () => myAlertDialogDeleteJournal(context, data),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),

          // title preview
          Text(
            '“$title”',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),

          // source label (optional)
          Text(
            'Source: ${source == 'local' ? 'SQLite' : 'Supabase'}',
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),

          const SizedBox(height: 8),

          Align(
            alignment: Alignment.bottomRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => JournalDetailPage(data: data),
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
