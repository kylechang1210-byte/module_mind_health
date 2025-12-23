import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'database_mindtrack.dart';
import 'supabase_connection.dart';

class MoodTrendPage extends StatefulWidget {
  const MoodTrendPage({super.key});

  @override
  State<MoodTrendPage> createState() => _MoodTrendPageState();
}

class _MoodTrendPageState extends State<MoodTrendPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _points = [];

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
          .map((row) => {
        ...row,
        'source': 'local',
      })
          .toList();

      // 2) Remote Supabase
      List<Map<String, dynamic>> remote = [];
      try {
        final supabase = SupabaseConnection.client;
        final data = await supabase
            .from('checkins')
            .select()
            .order('date', ascending: true); // oldest first

        remote = (data as List)
            .map<Map<String, dynamic>>((row) => {
          'id': row['id'],
          'date': row['date'],
          'mood': int.tryParse('${row['mood']}') ?? 0,
          'score': row['score'] ?? 0,
          'feelings': row['feelings'] ?? '',
          'notes': row['notes'] ?? '',
          'source': 'supabase',
        })
            .toList();
      } catch (_) {
        // if offline / Supabase error, just use local
      }

      // 3) Merge + dedup by id, prefer Supabase
      final Map<String, Map<String, dynamic>> uniqueById = {};

      for (final row in local) {
        final key = '${row['id']}';
        uniqueById[key] = row;
      }
      for (final row in remote) {
        final key = '${row['id']}';
        uniqueById[key] = row; // overwrite with remote if exists
      }

      final merged = uniqueById.values.toList()
        ..sort((a, b) {
          final ad = (a['date'] ?? '').toString();
          final bd = (b['date'] ?? '').toString();
          return ad.compareTo(bd); // oldest first
        });

      if (!mounted) return;
      setState(() {
        _points = merged;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load chart data: $e')),
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
          'Mood Trend',
          style: TextStyle(
            color: Color(0xFF6D5DF6),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _points.isEmpty
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
                    color: Colors.black.withValues(alpha:0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: LineChart(_buildLineChartData()),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _buildLineChartData() {
    final spots = <FlSpot>[];
    final labels = <int, String>{};

    for (int i = 0; i < _points.length; i++) {
      final row = _points[i];
      final score = (row['score'] ?? 0).toDouble();

      spots.add(FlSpot(i.toDouble(), score));

      final raw = (row['date'] ?? '').toString();
      String label;
      try {
        final dt = DateTime.parse(raw).toLocal();
        label = DateFormat('MM/dd').format(dt);
      } catch (_) {
        label = raw;
      }
      labels[i] = label;
    }

    return LineChartData(
      minY: 0,
      maxY: 100,
      gridData: FlGridData(show: true),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            getTitlesWidget: (value, meta) =>
                Text('${value.toInt()}', style: const TextStyle(fontSize: 10)),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final idx = value.toInt();
              final text = labels[idx] ?? '';
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 9),
                ),
              );
            },
          ),
        ),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          barWidth: 3,
          color: const Color(0xFF6D5DF6),
          dotData: FlDotData(show: true),
        ),
      ],
    );
  }
}
