import 'package:flutter/material.dart';
import 'database_mindtrack.dart';

class TherapyHistory extends StatefulWidget {
  const TherapyHistory({super.key});
  @override
  State<TherapyHistory> createState() => _TherapyHistoryState();
}

class _TherapyHistoryState extends State<TherapyHistory> {
  final Color _brandColor = const Color(0xFF7555FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f6fb),
      appBar: AppBar(
        title: const Text(
          'My Progress',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_brandColor, const Color(0xff5fc3ff)],
            ),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Clear History',
            onPressed: () async {
              await DatabaseMindTrack.instance.clearHistory();
              setState(() {});
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseMindTrack.instance.getHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  Text(
                    "No history yet. Start a session!",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          final historyList = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: historyList.length,
            itemBuilder: (context, index) {
              final item = historyList[index];
              String dateRaw = item['timestamp'];
              String dateShow = dateRaw.length > 16
                  ? dateRaw.substring(0, 16)
                  : dateRaw;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _brandColor.withValues(alpha: 0.1),
                    child: _getIcon(item['type']),
                  ),
                  title: Text(
                    item['detail'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(item['type']),
                  trailing: Text(
                    dateShow,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Icon _getIcon(String type) {
    if (type == 'Music'){
      return const Icon(Icons.music_note, color: Color(0xFF7555FF));

    }
    if (type == 'Breathing') return const Icon(Icons.air, color: Colors.blue);
    if (type == 'Movement'){
      return const Icon(Icons.fitness_center, color: Colors.orange);

    }
    return const Icon(Icons.check_circle, color: Colors.grey);
  }
}
