import 'package:flutter/material.dart';
import 'journal_history.dart';
import 'database_mindtrack.dart';
import 'supabase_connection.dart';

class JournalingPage extends StatefulWidget {
  const JournalingPage({super.key});

  @override
  State<JournalingPage> createState() => _JournalingPageState();
}

class _JournalingPageState extends State<JournalingPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  String _selectedMood = 'Meh';
  bool _isSaving = false;

  final List<String> moods = ['Sad', 'Meh', 'Okay', 'Good', 'Great'];

  // ---------- Supabase ----------

  Future<void> _saveJournalToSupabase({
    required String date,
    required String title,
    required String mood,
    required String content,
  }) async {
    final supabase = SupabaseConnection.client;

    await supabase.from('journals').insert({
      // id auto
      // date can be default now() in Supabase if you want
      'date': date,
      'title': title,
      'mood': mood,
      'content': content,
    });
  }

  // ---------- Alert dialogs ----------

  void _showSuccessDialog() {
    final dialog = AlertDialog(
      title: const Text('Success'),
      content: const Text('Journal saved successfully'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (_) => dialog,
    );
  }

  void _showErrorDialog(String message) {
    final dialog = AlertDialog(
      title: const Text('Error'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (_) => dialog,
    );
  }

  // ---------- Save (SQLite + Supabase) ----------

  Future<void> _onSaveJournal() async {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final dateStr = now.toIso8601String().substring(0, 10);
    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();
    final mood = _selectedMood;

    setState(() => _isSaving = true);

    try {
      // 1) Save to SQLite
      await DatabaseMindTrack.instance.insertJournal(
        date: dateStr,
        title: title,
        mood: mood,
        content: content,
      );

      // 2) Save to Supabase
      await _saveJournalToSupabase(
        date: dateStr,
        title: title,
        mood: mood,
        content: content,
      );

      if (!mounted) return;
      _showSuccessDialog();

      _titleCtrl.clear();
      _contentCtrl.clear();
      setState(() {
        _selectedMood = 'Meh';
      });
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Failed to save journal: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7FB),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const JournalHistoryPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderTitle(),
                const SizedBox(height: 20),
                _buildMoodRow(),
                const SizedBox(height: 20),
                _buildTitleField(),
                const SizedBox(height: 12),
                _buildContentField(),
                const SizedBox(height: 24),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderTitle() {
    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(
            text: 'Record ',
            style: TextStyle(
              color: Color(0xFF6D5DF6),
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: 'Your Day',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: moods.map((mood) {
        final selected = mood == _selectedMood;
        return GestureDetector(
          onTap: () {
            setState(() => _selectedMood = mood);
          },
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color:
                  selected ? const Color(0xFF7ED957) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    if (selected)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Text(
                  mood,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.black : Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleCtrl,
      decoration: InputDecoration(
        labelText: 'Title',
        hintText: 'e.g. Today is a bad day',
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Title is required.';
        }
        if (value.trim().length > 80) {
          return 'Keep the title under 80 characters.';
        }
        return null;
      },
    );
  }

  Widget _buildContentField() {
    return TextFormField(
      controller: _contentCtrl,
      maxLines: 6,
      decoration: InputDecoration(
        labelText: 'Journal',
        hintText: 'Write about your day...',
        alignLabelWithHint: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please write something about your day.';
        }
        return null;
      },
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _onSaveJournal,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          backgroundColor: const Color(0xFF6D5DF6),
        ),
        child: Text(
          _isSaving ? 'Saving...' : 'Save Journal',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
