import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminArticleManager extends StatefulWidget {
  const AdminArticleManager({super.key});

  @override
  State<AdminArticleManager> createState() => _AdminArticleManagerState();
}

class _AdminArticleManagerState extends State<AdminArticleManager> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _articles = [];
  bool _isLoading = true;

  // Controllers
  final _titleCtrl = TextEditingController();
  final _subCtrl = TextEditingController();
  final _imgCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchArticles();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subCtrl.dispose();
    _imgCtrl.dispose();
    _contentCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchArticles() async {
    setState(() => _isLoading = true);
    try {
      final data = await supabase.from('articles').select().order('id', ascending: false);
      setState(() {
        _articles = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveArticle({int? id}) async {
    if (_titleCtrl.text.isEmpty || _contentCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title and Content are required')));
      return;
    }

    final data = {
      'title': _titleCtrl.text.trim(),
      'subtitle': _subCtrl.text.trim(),
      'image': _imgCtrl.text.isNotEmpty ? _imgCtrl.text.trim() : 'https://placehold.co/600x400',
      'full_content': _contentCtrl.text.trim(),
      'url': _urlCtrl.text.isNotEmpty ? _urlCtrl.text.trim() : 'https://google.com',
    };

    try {
      if (id == null) {
        // CREATE (New)
        await supabase.from('articles').insert(data);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Article Posted!')));
      } else {
        // UPDATE (Edit)
        await supabase.from('articles').update(data).eq('id', id);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Article Updated!')));
      }

      if (mounted) Navigator.pop(context); // Close dialog
      _fetchArticles(); // Refresh list
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _deleteArticle(int id) async {
    // Confirm delete dialog
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Article?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text("Delete")),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await supabase.from('articles').delete().eq('id', id);
      _fetchArticles();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // Unified Dialog for Add AND Edit
  void _showArticleDialog({Map<String, dynamic>? article}) {
    // If article is null, we are ADDING. If not null, we are EDITING.
    if (article != null) {
      _titleCtrl.text = article['title'] ?? '';
      _subCtrl.text = article['subtitle'] ?? '';
      _imgCtrl.text = article['image'] ?? '';
      _contentCtrl.text = article['full_content'] ?? '';
      _urlCtrl.text = article['url'] ?? '';
    } else {
      _titleCtrl.clear();
      _subCtrl.clear();
      _imgCtrl.clear();
      _contentCtrl.clear();
      _urlCtrl.clear();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(article == null ? "Add New Article" : "Edit Article"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: "Title*")),
              TextField(controller: _subCtrl, decoration: const InputDecoration(labelText: "Subtitle")),
              TextField(controller: _imgCtrl, decoration: const InputDecoration(labelText: "Image URL")),
              TextField(controller: _urlCtrl, decoration: const InputDecoration(labelText: "External Link")),
              const SizedBox(height: 10),
              TextField(
                  controller: _contentCtrl,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: "Full Content*", border: OutlineInputBorder())
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            // Pass the ID if we are editing
            onPressed: () => _saveArticle(id: article?['id']),
            child: Text(article == null ? "Post" : "Save Changes"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Articles")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showArticleDialog(), // No argument = Add Mode
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _articles.length,
        itemBuilder: (context, index) {
          final item = _articles[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  item['image'] ?? '',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (c,e,s) => Container(width: 50, height: 50, color: Colors.grey.shade300, child: const Icon(Icons.article)),
                ),
              ),
              title: Text(item['title'] ?? 'No Title'),
              subtitle: Text(item['subtitle'] ?? ''),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // EDIT BUTTON
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showArticleDialog(article: item), // Pass item = Edit Mode
                  ),
                  // DELETE BUTTON
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteArticle(item['id']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}