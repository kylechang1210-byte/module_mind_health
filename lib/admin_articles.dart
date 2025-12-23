import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ArticleManagerTab extends StatefulWidget {
  const ArticleManagerTab({super.key});

  @override
  State<ArticleManagerTab> createState() => ArticleManagerTabState();
}

class ArticleManagerTabState extends State<ArticleManagerTab> {
  final supabase = Supabase.instance.client;
  final Color _brandColor = const Color(0xFF7555FF);
  List<Map<String, dynamic>> _articles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchArticles();
  }

  Future<void> _fetchArticles() async {
    setState(() => _isLoading = true);
    try {
      final data = await supabase
          .from('articles')
          .select()
          .order('id', ascending: false);
      setState(() {
        _articles = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteArticle(int id) async {
    try {
      await supabase.from('articles').delete().eq('id', id);
      _fetchArticles();
    } catch (e) {
      if (mounted){
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  // --- PUBLIC METHOD FOR DASHBOARD FAB ---
  void showAddArticleSheet() => _showArticleForm();

  // --- UNIFIED BOTTOM SHEET UI ---
  void _showArticleForm({Map<String, dynamic>? article}) {
    final isEdit = article != null;
    final titleCtrl = TextEditingController(
      text: isEdit ? article['title'] : '',
    );
    final subCtrl = TextEditingController(
      text: isEdit ? article['subtitle'] : '',
    );
    final imgCtrl = TextEditingController(text: isEdit ? article['image'] : '');
    final contentCtrl = TextEditingController(
      text: isEdit ? article['full_content'] : '',
    );
    final urlCtrl = TextEditingController(text: isEdit ? article['url'] : '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (ctx) => Padding(
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
              isEdit ? "Edit Article" : "New Article",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _brandColor,
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: subCtrl,
              decoration: const InputDecoration(labelText: "Subtitle"),
            ),
            TextField(
              controller: imgCtrl,
              decoration: const InputDecoration(labelText: "Image URL"),
            ),
            TextField(
              controller: contentCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "Full Content"),
            ),
            TextField(
              controller: urlCtrl,
              decoration: const InputDecoration(
                labelText: "External URL (Optional)",
              ),
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brandColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  Navigator.pop(ctx);
                  final data = {
                    'title': titleCtrl.text.trim(),
                    'subtitle': subCtrl.text.trim(),
                    'image': imgCtrl.text.trim(),
                    'full_content': contentCtrl.text.trim(),
                    'url': urlCtrl.text.trim(),
                  };
                  try {
                    if (isEdit) {
                      await supabase
                          .from('articles')
                          .update(data)
                          .eq('id', article['id']);
                    } else {
                      await supabase.from('articles').insert(data);
                    }
                    _fetchArticles();
                  } catch (e) {
                    if (mounted){
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text("Error: $e")));
                    }
                  }
                },
                child: const Text("SAVE DATA"),
              ),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 80),
            itemCount: _articles.length,
            itemBuilder: (context, index) {
              final item = _articles[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 2,
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item['image'] ?? '',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey.shade300,
                        child: Icon(Icons.article, color: _brandColor),
                      ),
                    ),
                  ),
                  title: Text(
                    item['title'] ?? 'No Title',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    item['subtitle'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showArticleForm(article: item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteArticle(item['id']),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }
}
