import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'database_mindtrack.dart';
import 'supabase_connection.dart';

class MoodDistributionPage extends StatefulWidget {
  const MoodDistributionPage({super.key});

  @override
  State<MoodDistributionPage> createState() => _MoodDistributionPageState();
}

class _MoodDistributionPageState extends State<MoodDistributionPage> {
  bool _isLoading = true;
  Map<int, int> _counts = {}; // mood -> count

  static const moods = ['Terrible', 'Meh', 'Fine', 'Good', 'Great'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // =============== LOAD FROM SQLITE + SUPABASE WITH DEDUP ===============

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // 1) Local SQLite
      final localRows = await DatabaseMindTrack.instance.getAllCheckIns();
      final local = localRows
          .map((row) => {...row, 'source': 'local'})
          .toList();

      // 2) Remote Supabase
      List<Map<String, dynamic>> remote = [];
      try {
        final supabase = SupabaseConnection.client;
        final data = await supabase
            .from('checkins')
            .select()
            .order('date', ascending: true);

        remote = (data as List)
            .map<Map<String, dynamic>>(
              (row) => {
                'id': row['id'],
                'date': row['date'],
                'mood': int.tryParse('${row['mood']}') ?? 0,
                'score': row['score'] ?? 0,
                'feelings': row['feelings'] ?? '',
                'notes': row['notes'] ?? '',
                'source': 'supabase',
              },
            )
            .toList();
      } catch (_) {
        // ignore if offline
      }

      // 3) Merge + dedup by id, prefer Supabase
      final Map<String, Map<String, dynamic>> uniqueById = {};

      for (final row in local) {
        final key = '${row['id']}';
        uniqueById[key] = row;
      }
      for (final row in remote) {
        final key = '${row['id']}';
        uniqueById[key] = row;
      }

      final merged = uniqueById.values.toList();

      // 4) Aggregate counts by mood
      final counts = <int, int>{};
      for (final row in merged) {
        final mood = row['mood'] ?? 0;
        counts[mood] = (counts[mood] ?? 0) + 1;
      }

      if (!mounted) return;
      setState(() {
        _counts = counts;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load distribution: $e')),
      );
    }
  }

  // ============================= UI =============================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7FB),
        elevation: 0,
        title: const Text(
          'Mood Distribution',
          style: TextStyle(
            color: Color(0xFF6D5DF6),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _counts.isEmpty
          ? const Center(child: Text('No check-ins yet.'))
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    height: 260,
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
                    child: PieChart(_buildPieChartData()),
                  ),
                  const SizedBox(height: 16),
                  _buildLegend(),
                ],
              ),
            ),
    );
  }

  PieChartData _buildPieChartData() {
    final total = _counts.values.fold<int>(
      0,
      (prev, element) => prev + element,
    );
    final colors = [
      const Color(0xFFEF476F),
      const Color(0xFFF78C6B),
      const Color(0xFFFED766),
      const Color(0xFF06D6A0),
      const Color(0xFF118AB2),
    ];

    final sections = <PieChartSectionData>[];

    _counts.forEach((mood, count) {
      final percentage = total == 0 ? 0 : (count / total) * 100;
      final color = colors[mood % colors.length];
      sections.add(
        PieChartSectionData(
          color: color,
          value: count.toDouble(),
          title: '${percentage.toStringAsFixed(0)}%',
          radius: 70,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    });

    return PieChartData(
      sections: sections,
      centerSpaceRadius: 40,
      sectionsSpace: 2,
    );
  }

  Widget _buildLegend() {
    final colors = [
      const Color(0xFFEF476F),
      const Color(0xFFF78C6B),
      const Color(0xFFFED766),
      const Color(0xFF06D6A0),
      const Color(0xFF118AB2),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: List.generate(moods.length, (i) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: colors[i],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 4),
            Text(moods[i], style: const TextStyle(fontSize: 12)),
          ],
        );
      }),
    );
  }
}
