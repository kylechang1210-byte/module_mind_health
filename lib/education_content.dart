import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'app_config.dart';
import 'database_helper.dart'; // SQLite

class EducationContentScreen extends StatefulWidget {
  const EducationContentScreen({super.key});
  @override
  State<EducationContentScreen> createState() => _EducationContentScreenState();
}

class _EducationContentScreenState extends State<EducationContentScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _articles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchContent();
  }

  Future<void> _fetchContent() async {
    try {
      final data = await supabase.from('articles').select().order('id', ascending: false);
      setState(() { _articles = List<Map<String, dynamic>>.from(data); _isLoading = false; });
    } catch (e) { setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundBlue,
      appBar: AppBar(
        title: const Text("Educational Content"),
        actions: [IconButton(icon: const Icon(Icons.favorite, color: Colors.white), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen())))],
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : _articles.isEmpty ? const Center(child: Text("No articles yet.")) : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _articles.length,
        itemBuilder: (context, index) {
          final item = _articles[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))]),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                width: 50, height: 50, decoration: BoxDecoration(color: kLightBlueIconBg, borderRadius: BorderRadius.circular(10)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: item['image'] != null && item['image'].toString().isNotEmpty
                      ? Image.network(item['image'], fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.article, color: kPrimaryBlue))
                      : const Icon(Icons.article, color: kPrimaryBlue),
                ),
              ),
              title: Text(item['title'] ?? 'No Title', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
              subtitle: Text(item['subtitle'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ArticleDetailScreen(data: item))),
            ),
          );
        },
      ),
    );
  }
}

class ArticleDetailScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final int readTime;
  ArticleDetailScreen({super.key, required this.data, int? readTime}) : readTime = readTime ?? (data['fullContent'].toString().split(' ').length / 50).ceil();
  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  bool isSaved = false;
  late Timer _timer;
  int _remainingSeconds = 0;
  bool _isTimerRunning = true;

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
    String content = widget.data['full_content'] ?? widget.data['fullContent'] ?? "";
    int estimatedTime = (content.split(' ').length / 50).ceil();
    if (estimatedTime < 1) estimatedTime = 1;
    _remainingSeconds = estimatedTime * 60;
    _startTimer();
  }

  Future<void> _checkIfSaved() async {
    bool exists = await DatabaseHelper.instance.isFavorite(widget.data['id'].toString());
    if (mounted) setState(() => isSaved = exists);
  }

  void _toggleFavorite() async {
    if (isSaved) {
      await DatabaseHelper.instance.removeFavorite(widget.data['id'].toString());
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Removed from offline storage")));
    } else {
      await DatabaseHelper.instance.addFavorite(widget.data);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saved for offline reading!")));
    }
    setState(() => isSaved = !isSaved);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) setState(() => _remainingSeconds--);
      else { _timer.cancel(); setState(() => _isTimerRunning = false); }
    });
  }

  @override
  void dispose() { _timer.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final String title = widget.data['title'] ?? "No Title";
    final String image = widget.data['image'] ?? "https://placehold.co/600x400";
    final String content = widget.data['full_content'] ?? widget.data['fullContent'] ?? "No content available.";
    final String url = widget.data['url'] ?? "https://google.com";

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 250.0, pinned: true, backgroundColor: kPrimaryBlue,
          flexibleSpace: FlexibleSpaceBar(background: Hero(tag: "img_${widget.data['id']}", child: Image.network(image, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: Colors.grey, child: const Icon(Icons.broken_image, size: 50))))),
          actions: [
            IconButton(onPressed: () => Share.share("Read '$title': $url"), icon: const Icon(Icons.share, color: Colors.white)),
            IconButton(onPressed: _toggleFavorite, icon: Icon(isSaved ? Icons.favorite : Icons.favorite_border, color: isSaved ? Colors.red : Colors.white)),
          ],
        ),
        SliverList(delegate: SliverChildListDelegate([
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: _isTimerRunning ? Colors.orange.shade50 : Colors.green.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: _isTimerRunning ? Colors.orange.shade200 : Colors.green.shade200)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(_isTimerRunning ? Icons.timer : Icons.check_circle, size: 18, color: _isTimerRunning ? Colors.orange.shade800 : Colors.green),
                  const SizedBox(width: 8),
                  Text(_isTimerRunning ? "${(_remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(_remainingSeconds % 60).toString().padLeft(2, '0')} left" : "Goal Completed!", style: TextStyle(color: _isTimerRunning ? Colors.orange.shade900 : Colors.green.shade800, fontWeight: FontWeight.bold)),
                ]),
              ),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF004D40), height: 1.2)),
              const SizedBox(height: 20),
              Text(content, style: TextStyle(fontSize: 16, height: 1.8, color: Colors.grey.shade800)),
              const SizedBox(height: 40),
              SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication), icon: const Icon(Icons.public, size: 18), label: const Text("Open Website"))),
              const SizedBox(height: 40),
            ]),
          ),
        ])),
      ]),
    );
  }
}

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<Map<String, dynamic>>> _favs;
  @override
  void initState() { super.initState(); _refresh(); }
  void _refresh() { setState(() { _favs = DatabaseHelper.instance.getFavorites(); }); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Offline Favorites")),
      body: FutureBuilder(
        future: _favs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || (snapshot.data as List).isEmpty) return const Center(child: Text("No favorites yet."));
          final list = snapshot.data as List;
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return ListTile(
                leading: Image.network(item['image'], width: 50, fit: BoxFit.cover),
                title: Text(item['title']),
                trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async { await DatabaseHelper.instance.removeFavorite(item['id']); _refresh(); }),
                onTap: () {
                  final data = Map<String, dynamic>.from(item);
                  if (item['colorValue'] != null) data['color'] = Color(item['colorValue']);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ArticleDetailScreen(data: data)));
                },
              );
            },
          );
        },
      ),
    );
  }
}