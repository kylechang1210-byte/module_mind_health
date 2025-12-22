import 'package:flutter/material.dart';
import 'database_mindtrack.dart';

class TherapyAdmin extends StatefulWidget {
  const TherapyAdmin({super.key});

  @override
  State<TherapyAdmin> createState() => _TherapyAdminState();
}

class _TherapyAdminState extends State<TherapyAdmin> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Color _brandColor = const Color(0xFF7555FF); // Consistent Brand Color
  int _selectedIconCode = 0xe6bd; // Default icon

  // A list of icons relevant to your module
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
    _tabController = TabController(length: 2, vsync: this);
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f6fb),
      appBar: AppBar(
        title: const Text('Admin Management', style: TextStyle(fontWeight: FontWeight.bold)),
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
          tabs: const [
            Tab(icon: Icon(Icons.library_music), text: "Music"),
            Tab(icon: Icon(Icons.run_circle), text: "Movement"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildListSection('music'),
          _buildListSection('movement'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _brandColor,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          _selectedIconCode = 0xe6bd; // Reset default icon for new entry
          _tabController.index == 0 ? _showMusicForm(context) : _showMovementForm(context);
        },
      ),
    );
  }

  // Generic list builder for both tabs to keep UI consistent
  Widget _buildListSection(String type) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: type == 'music'
          ? DatabaseMindTrack.instance.getAllMusic()
          : DatabaseMindTrack.instance.getExercises(null),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.isEmpty) return const Center(child: Text("No items found."));

        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final item = snapshot.data![index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _brandColor.withOpacity(0.1),
                  child: Icon(IconData(item['iconCode'], fontFamily: 'MaterialIcons'), color: _brandColor),
                ),
                title: Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(item['description'], maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        _selectedIconCode = item['iconCode']; // Load existing icon
                        type == 'music' ? _showMusicForm(context, item: item) : _showMovementForm(context, item: item);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        type == 'music'
                            ? await DatabaseMindTrack.instance.deleteMusic(item['id'])
                            : await DatabaseMindTrack.instance.deleteExercise(item['id']);
                        _refresh();
                      },
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

  // --- ICON PICKER WIDGET ---
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
                  setModalState(() {
                    _selectedIconCode = entry.value.codePoint;
                  });
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

  // --- FORMS ---
  void _showMusicForm(BuildContext context, {Map<String, dynamic>? item}) {
    final bool isEdit = item != null;
    final titleCtrl = TextEditingController(text: isEdit ? item['title'] : '');
    final descCtrl = TextEditingController(text: isEdit ? item['description'] : '');
    final pathCtrl = TextEditingController(text: isEdit ? item['audioPath'] : 'assets/audio/');

    _openFormSheet(
      title: isEdit ? "Edit Music Track" : "Add New Music",
      onSave: () async {
        final data = {
          if (isEdit) 'id': item['id'],
          'title': titleCtrl.text,
          'description': descCtrl.text,
          'iconCode': _selectedIconCode,
          'audioPath': pathCtrl.text,
        };
        isEdit ? await DatabaseMindTrack.instance.updateMusic(data) : await DatabaseMindTrack.instance.insertMusic(data);
        _refresh();
      },
      content: (setModalState) => [
        TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "Title")),
        TextField(controller: descCtrl, decoration: const InputDecoration(labelText: "Description")),
        TextField(controller: pathCtrl, decoration: const InputDecoration(labelText: "Audio Path")),
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
          if (isEdit) 'id': item['id'],
          'category': category,
          'title': titleCtrl.text,
          'description': descCtrl.text,
          'iconCode': _selectedIconCode,
        };
        isEdit ? await DatabaseMindTrack.instance.updateExercise(data) : await DatabaseMindTrack.instance.insertExercise(data);
        _refresh();
      },
      content: (setModalState) => [
        DropdownButtonFormField<String>(
          value: category,
          items: ['Yoga', 'Pilates', 'Walking', 'Tai Chi'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
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

  // --- HELPER SHEET ---
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
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: _brandColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  onPressed: () { onSave(); Navigator.pop(context); },
                  child: const Text("SAVE DATA", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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