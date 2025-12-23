import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'user_manager.dart';
import 'admin_articles.dart';

// CONSTANTS & STYLES
class _AppColors {
  static const Color brandPurple = Color(0xFF7555FF);
  static const Color brandBlue = Color(0xff5fc3ff);
  static const Color background = Color(0xfff3f6fb);

  static const LinearGradient mainGradient = LinearGradient(
    colors: [brandPurple, brandBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;
  final _supabase = Supabase.instance.client;

  // trigger Add Article
  final GlobalKey<ArticleManagerTabState> _articleKey = GlobalKey();

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
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.background,
      appBar: _buildAppBar(),
      body: TabBarView(
        controller: _tabController,
        children: [
          const UserListTab(),                 // Tab 1: Users
          ArticleManagerTab(key: _articleKey), // Tab 2: Articles
          _buildListSection('music'),          // Tab 3: Music
          _buildListSection('movement'),       // Tab 4: Movement
          _buildHistorySection(),              // Tab 5: Logs
        ],
      ),
      floatingActionButton: _buildFloatingButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Admin Dashboard',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: _AppColors.mainGradient),
      ),
      foregroundColor: Colors.white,
      bottom: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: Colors.white,
        indicatorWeight: 4,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: const [
          Tab(icon: Icon(Icons.people), text: "Users"),
          Tab(icon: Icon(Icons.article), text: "Content"),
          Tab(icon: Icon(Icons.library_music), text: "Music"),
          Tab(icon: Icon(Icons.run_circle), text: "Movement"),
          Tab(icon: Icon(Icons.history), text: "Logs"),
        ],
      ),
    );
  }

  Widget? _buildFloatingButton() {
    final index = _tabController.index;

    if (index == 1) {
      return FloatingActionButton(
        backgroundColor: _AppColors.brandPurple,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _articleKey.currentState?.showAddArticleSheet(),
      );
    } else if (index == 2) {
      return FloatingActionButton(
        backgroundColor: _AppColors.brandPurple,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          _selectedIconCode = 0xe6bd;
          _showMusicForm(context);
        },
      );
    } else if (index == 3) {
      return FloatingActionButton(
        backgroundColor: _AppColors.brandPurple,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          _selectedIconCode = 0xe6bd;
          _showMovementForm(context);
        },
      );
    }
    return null;
  }

  // SUPABASE
  Future<List<Map<String, dynamic>>> _fetchData(String table) async {
    final String orderBy = table == 'history' ? 'timestamp' : 'id';
    final bool ascending = table != 'history';

    final response = await _supabase
        .from(table)
        .select()
        .order(orderBy, ascending: ascending);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> _deleteItem(String table, int id) async {
    try {
      await _supabase.from(table).delete().eq('id', id);
      setState(() {}); // Refresh UI
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  String _formatDate(String raw) {
    try {
      return DateFormat('MMM d, h:mm a').format(DateTime.parse(raw).toLocal());
    } catch (_) {
      return raw;
    }
  }


  // List for Music & Movement
  Widget _buildListSection(String table) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchData(table),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data!.isEmpty) {
          return Center(child: Text("No $table items found."));
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 80),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final item = snapshot.data![index];
            final iconCode = item['icon_code'] ?? 0xe6bd;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _AppColors.brandPurple.withValues(alpha: 0.1),
                  child: Icon(
                    IconData(iconCode, fontFamily: 'MaterialIcons'),
                    color: _AppColors.brandPurple,
                  ),
                ),
                title: Text(
                  item['title'] ?? 'No Title',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(item['description'] ?? '', maxLines: 1),
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

  // History
  Widget _buildHistorySection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchData('history'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data!.isEmpty) {
          return const Center(child: Text("No logs."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final item = snapshot.data![index];
            final type = item['type'] ?? 'Activity';

            // Icon Logic for Logs
            IconData icon = Icons.history;
            Color color = Colors.grey;
            if (type == 'Music') {
              icon = Icons.music_note;
              color = Colors.purple;
            } else if (type == 'Breathing') {
              icon = Icons.air;
              color = Colors.blue;
            } else if (type == 'Movement') {
              icon = Icons.directions_run;
              color = Colors.orange;
            }

            return Card(
              child: ListTile(
                leading: Icon(icon, color: color),
                title: Text(
                  item['detail'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "$type • ${_formatDate(item['timestamp'] ?? '')}",
                ),
              ),
            );
          },
        );
      },
    );
  }

  // FORMS
  // Icon Picker Widget
  Widget _buildIconPicker(StateSetter setModalState) {
    return SizedBox(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _availableIcons.entries.map((e) {
          bool isSelected = _selectedIconCode == e.value.codePoint;
          return GestureDetector(
            onTap: () => setModalState(() => _selectedIconCode = e.value.codePoint),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? _AppColors.brandPurple : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(
                e.value,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _openFormSheet({
    required String title,
    required Function onSave,
    required List<Widget> Function(StateSetter) content,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 25,
            right: 25,
            top: 25,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _AppColors.brandPurple,
                ),
              ),
              const SizedBox(height: 15),

              ...content(setModalState),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _AppColors.brandPurple,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    onSave();
                    Navigator.pop(ctx);
                  },
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

  // Form Music
  void _showMusicForm(BuildContext context, {Map<String, dynamic>? item}) {
    final bool isEdit = item != null;
    final tCtrl = TextEditingController(text: isEdit ? item['title'] : '');
    final dCtrl = TextEditingController(text: isEdit ? item['description'] : '');
    final pCtrl = TextEditingController(
      text: isEdit ? (item['audio_path'] ?? item['audioPath']) : 'assets/audio/',
    );

    _openFormSheet(
      title: isEdit ? "Edit Music" : "Add Music",
      onSave: () async {
        final data = {
          'title': tCtrl.text,
          'description': dCtrl.text,
          'icon_code': _selectedIconCode,
          'audio_path': pCtrl.text,
        };
        isEdit
            ? await _supabase.from('music').update(data).eq('id', item['id'])
            : await _supabase.from('music').insert(data);
        setState(() {});
      },
      content: (s) => [
        TextField(
          controller: tCtrl,
          decoration: const InputDecoration(labelText: "Title"),
        ),
        TextField(
          controller: dCtrl,
          decoration: const InputDecoration(labelText: "Description"),
        ),
        TextField(
          controller: pCtrl,
          decoration: const InputDecoration(labelText: "Audio Path / URL"),
        ),
        const SizedBox(height: 20),
        _buildIconPicker(s),
      ],
    );
  }

  //  Form Movement
  void _showMovementForm(BuildContext context, {Map<String, dynamic>? item}) {
    final bool isEdit = item != null;
    String cat = isEdit ? item['category'] : 'Yoga';
    final tCtrl = TextEditingController(text: isEdit ? item['title'] : '');
    final dCtrl = TextEditingController(text: isEdit ? item['description'] : '');

    _openFormSheet(
      title: isEdit ? "Edit Movement" : "Add Movement",
      onSave: () async {
        final data = {
          'category': cat,
          'title': tCtrl.text,
          'description': dCtrl.text,
          'icon_code': _selectedIconCode,
        };
        isEdit
            ? await _supabase.from('movement').update(data).eq('id', item['id'])
            : await _supabase.from('movement').insert(data);
        setState(() {});
      },
      content: (s) => [
        DropdownButtonFormField<String>(
          initialValue: cat,
          items: ['Yoga', 'Pilates', 'Walking', 'Tai Chi']
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (v) => cat = v!,
          decoration: const InputDecoration(labelText: "Category"),
        ),
        TextField(
          controller: tCtrl,
          decoration: const InputDecoration(labelText: "Title"),
        ),
        TextField(
          controller: dCtrl,
          maxLines: 2,
          decoration: const InputDecoration(labelText: "Instructions"),
        ),
        const SizedBox(height: 20),
        _buildIconPicker(s),
      ],
    );
  }
}