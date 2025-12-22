import 'package:flutter/material.dart';
import 'database_mindtrack.dart';
import 'checkin_detail.dart';

class CheckInHistoryPage extends StatefulWidget {
  const CheckInHistoryPage({super.key});

  @override
  State<CheckInHistoryPage> createState() => _CheckInHistoryPageState();
}

class _CheckInHistoryPageState extends State<CheckInHistoryPage> {
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final data = await DatabaseMindTrack.instance.getAllCheckIns();
    setState(() {
      items = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check-In History')),
      body: items.isEmpty
          ? const Center(child: Text('No check-ins yet'))
          : ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final row = items[index];
          return ListTile(
            title: Text(
              '${row['date']}  •  ${row['score']}%',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(row['feelings'] ?? ''),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CheckInDetailPage(data: row),
                ),
              );
            },
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await DatabaseMindTrack.instance
                    .deleteCheckIn(row['id'] as int);
                _loadHistory();
              },
            ),
          );
        },
      ),
    );
  }
}
