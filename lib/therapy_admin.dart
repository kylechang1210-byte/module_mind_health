import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class TherapyAdmin extends StatefulWidget {
  const TherapyAdmin({super.key});
  @override
  State<TherapyAdmin> createState() => _TherapyAdminState();
}

class _TherapyAdminState extends State<TherapyAdmin>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _supabase = Supabase.instance.client;
  final Color _brandColor = const Color(0xFF7555FF);
  int _selectedIconCode = 0xe6bd;

  final Map<String, IconData> _availableIcons = {
    'Music': Icons.music_note,
    'Rain': Icons.water_drop,
    'Nature': Icons.forest,
    'Focus': Icons.headphones,
    'Waves': Icons.waves,
    'Yoga': Icons.self_improvement,
    'Exercise': Icons.fitness_center,
    'Walk': Icons.directions_walk,
    'Timer': Icons.timer,
    'Cloud': Icons.cloud,
  };

  @override
  void initState() {
    super.initState();
    // CHANGED: Length is now 3 to include "User Logs"
    _tabController = TabController(length: 3, vsync: this);
  }

  // --- FETCH DATA FROM SUPABASE ---
  Future<List<Map<String, dynamic>>> _fetchData(String table) async {
    // If fetching history, order by timestamp (newest first). Otherwise by ID.
    final String orderBy = table == 'history' ? 'timestamp' : 'id';
    final bool ascending = table != 'history';

    final response = await _supabase
        .from(table)
        .select()
        .order(orderBy, ascending: ascending);
    return List<Map<String, dynamic>>.from(response);
  }

  // --- DELETE DATA FROM SUPABASE ---
  Future<void> _deleteItem(String table, int id) async {
    try {
      await _supabase.from(table).delete().eq('id', id);
      setState(() {}); // Refresh UI
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  // --- FORMAT DATE HELPER ---
  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      return DateFormat('MMM d, h:mm a').format(dt);
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f6fb),
      appBar: AppBar(
        title: const Text('Manage Therapy', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [_brandColor, const Color(0xff5fc3ff)]),
          ),
        ),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 4,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.library_music), text: "Music"),
            Tab(icon: Icon(Icons.run_circle), text: "Movement"),
            // NEW TAB
            Tab(icon: Icon(Icons.history), text: "User Logs"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildListSection('music'),
          _buildListSection('movement'),
          _buildHistorySection(), // NEW SECTION
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _brandColor,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          // Disable Add button on History tab
          if (_tabController.index == 2) return;

          _selectedIconCode = 0xe6bd;
          _tabController.index == 0
              ? _showMusicForm(context)
              : _showMovementForm(context);
        },
      ),
    );
  }

  // --- BUILDER FOR MUSIC & MOVEMENT ---
  Widget _buildListSection(String table) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchData(table),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("No $table items found."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final item = snapshot.data![index];
            final iconCode = item['icon_code'] ?? item['iconCode'] ?? 0xe6bd;

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _brandColor.withOpacity(0.1),
                  child: Icon(IconData(iconCode, fontFamily: 'MaterialIcons'), color: _brandColor),
                ),
                title: Text(item['title'] ?? 'No Title', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(item['description'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        _selectedIconCode = iconCode;
                        table == 'music'
                            ? _showMusicForm(context, item: item)
                            : _showMovementForm(context, item: item);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteItem(table, item['id']),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- BUILDER FOR HISTORY LOGS ---
  Widget _buildHistorySection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchData('history'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No user history logs found."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final item = snapshot.data![index];
            final type = item['type'] ?? 'Activity';
            final detail = item['detail'] ?? '';
            final time = _formatDate(item['timestamp'] ?? '');

            // Icon logic based on type
            IconData icon = Icons.history;
            Color color = Colors.grey;
            if (type == 'Music') { icon = Icons.music_note; color = Colors.purple; }
            if (type == 'Breathing') { icon = Icons.air; color = Colors.blue; }
            if (type == 'Movement') { icon = Icons.directions_run; color = Colors.orange; }

            return Card(
              elevation: 1,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(icon, color: color),
                title: Text(detail, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("$type • $time"),
                // Optional: Show partial User ID to identify who did it
                // trailing: Text(item['user_id'] != null ? '...${item['user_id'].toString().substring(0,4)}' : ''),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildIconPicker(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select Icon:", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SizedBox(
          height: 60,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: _availableIcons.entries.map((entry) {
              bool isSelected = _selectedIconCode == entry.value.codePoint;
              return GestureDetector(
                onTap: () {
                  setModalState(() => _selectedIconCode = entry.value.codePoint);
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? _brandColor : Colors.grey[200],
                    shape: BoxShape.circle,
                    border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                  ),
                  child: Icon(entry.value, color: isSelected ? Colors.white : Colors.grey[600]),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showMusicForm(BuildContext context, {Map<String, dynamic>? item}) {
    final bool isEdit = item != null;
    final titleCtrl = TextEditingController(text: isEdit ? item['title'] : '');
    final descCtrl = TextEditingController(text: isEdit ? item['description'] : '');
    final pathCtrl = TextEditingController(text: isEdit ? (item['audio_path'] ?? item['audioPath']) : 'assets/audio/');

    _openFormSheet(
      title: isEdit ? "Edit Music Track" : "Add New Music",
      onSave: () async {
        final data = {
          'title': titleCtrl.text,
          'description': descCtrl.text,
          'icon_code': _selectedIconCode,
          'audio_path': pathCtrl.text,
        };
        if (isEdit) {
          await _supabase.from('music').update(data).eq('id', item['id']);
        } else {
          await _supabase.from('music').insert(data);
        }
        setState(() {});
      },
      content: (setModalState) => [
        TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "Title")),
        TextField(controller: descCtrl, decoration: const InputDecoration(labelText: "Description")),
        TextField(controller: pathCtrl, decoration: const InputDecoration(labelText: "Audio Path / URL")),
        const SizedBox(height: 20),
        _buildIconPicker(setModalState),
      ],
    );
  }

  void _showMovementForm(BuildContext context, {Map<String, dynamic>? item}) {
    final bool isEdit = item != null;
    String category = isEdit ? item['category'] : 'Yoga';
    final titleCtrl = TextEditingController(text: isEdit ? item['title'] : '');
    final descCtrl = TextEditingController(text: isEdit ? item['description'] : '');

    _openFormSheet(
      title: isEdit ? "Edit Movement" : "Add New Movement",
      onSave: () async {
        final data = {
          'category': category,
          'title': titleCtrl.text,
          'description': descCtrl.text,
          'icon_code': _selectedIconCode,
        };
        if (isEdit) {
          await _supabase.from('movement').update(data).eq('id', item['id']);
        } else {
          await _supabase.from('movement').insert(data);
        }
        setState(() {});
      },
      content: (setModalState) => [
        DropdownButtonFormField<String>(
          value: category,
          items: ['Yoga', 'Pilates', 'Walking', 'Tai Chi']
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (val) => category = val!,
          decoration: const InputDecoration(labelText: "Category"),
        ),
        TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "Exercise Title")),
        TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: "Instructions")),
        const SizedBox(height: 20),
        _buildIconPicker(setModalState),
      ],
    );
  }

  void _openFormSheet({required String title, required Function onSave, required List<Widget> Function(StateSetter) content}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 25, right: 25, top: 25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _brandColor)),
              const SizedBox(height: 15),
              ...content(setModalState),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: _brandColor, foregroundColor: Colors.white),
                  onPressed: () { onSave(); Navigator.pop(context); },
                  child: const Text("SAVE DATA"),
                ),
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}