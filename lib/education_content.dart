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

  // Brand Colors
  final Color _brandPurple = const Color(0xff7b3df0);
  final Color _brandBlue = const Color(0xff5fc3ff);

  @override
  void initState() {
    super.initState();
    _fetchContent();
  }

  Future<void> _fetchContent() async {
    try {
      final data = await supabase.from('articles').select().order('id', ascending: false);
      setState(() {
        _articles = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB), // Matches App Theme
      appBar: AppBar(
        title: const Text("Educational Content", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        // Gradient AppBar
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_brandPurple, _brandBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavoritesScreen()),
            ),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _articles.isEmpty
          ? const Center(child: Text("No articles yet."))
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _articles.length,
        itemBuilder: (context, index) {
          final item = _articles[index];
          return _ArticleCard(item: item);
        },
      ),
    );
  }
}

// --- GRADIENT ARTICLE CARD ---
class _ArticleCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const _ArticleCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 100, // Fixed height for consistency
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        // Gradient Background
        gradient: const LinearGradient(
          colors: [Color(0xff7b3df0), Color(0xff5fc3ff)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff7b3df0).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ArticleDetailScreen(data: item)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Image Thumbnail with white border
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: item['image'] != null && item['image'].toString().isNotEmpty
                        ? Image.network(
                      item['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => const Icon(Icons.article, color: Colors.white),
                    )
                        : const Icon(Icons.article, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item['title'] ?? 'No Title',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['subtitle'] ?? 'Read more...',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow Icon
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- DETAIL SCREEN ---
class ArticleDetailScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final int readTime;
  ArticleDetailScreen({super.key, required this.data, int? readTime})
      : readTime = readTime ?? (data['full_content'].toString().split(' ').length / 50).ceil();
  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  bool isSaved = false;
  late Timer _timer;
  int _remainingSeconds = 0;
  bool _isTimerRunning = true;
  final Color _brandPurple = const Color(0xff7b3df0);

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
    String content = widget.data['full_content'] ?? widget.data['fullContent'] ?? "";
    int estimatedTime = (content.split(' ').length / 150).ceil(); // Adjusted reading speed
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
      if (_remainingSeconds > 0) {
        if (mounted) setState(() => _remainingSeconds--);
      } else {
        _timer.cancel();
        if (mounted) setState(() => _isTimerRunning = false);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.data['title'] ?? "No Title";
    final String image = widget.data['image'] ?? "";
    final String content = widget.data['full_content'] ?? widget.data['fullContent'] ?? "No content available.";
    final String url = widget.data['url'] ?? "https://google.com";

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 250.0,
          pinned: true,
          backgroundColor: _brandPurple, // Brand Color
          flexibleSpace: FlexibleSpaceBar(
            background: image.isNotEmpty
                ? Hero(
              tag: "img_${widget.data['id']}",
              child: Image.network(
                image,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(color: _brandPurple.withOpacity(0.5), child: const Icon(Icons.article, size: 50, color: Colors.white)),
              ),
            )
                : Container(color: _brandPurple),
          ),
          actions: [
            IconButton(onPressed: () => Share.share("Read '$title': $url"), icon: const Icon(Icons.share, color: Colors.white)),
            IconButton(
              onPressed: _toggleFavorite,
              icon: Icon(isSaved ? Icons.favorite : Icons.favorite_border, color: isSaved ? Colors.redAccent : Colors.white),
            ),
          ],
        ),
        SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Timer Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _isTimerRunning ? Colors.orange.shade50 : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _isTimerRunning ? Colors.orange.shade200 : Colors.green.shade200),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(_isTimerRunning ? Icons.timer : Icons.check_circle, size: 18, color: _isTimerRunning ? Colors.orange.shade800 : Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        _isTimerRunning
                            ? "${(_remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(_remainingSeconds % 60).toString().padLeft(2, '0')} left"
                            : "Goal Completed!",
                        style: TextStyle(color: _isTimerRunning ? Colors.orange.shade900 : Colors.green.shade800, fontWeight: FontWeight.bold),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF2D3436), height: 1.2)),
                  const SizedBox(height: 20),
                  Text(content, style: TextStyle(fontSize: 16, height: 1.8, color: Colors.grey.shade800)),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
                      icon: const Icon(Icons.public, size: 18),
                      label: const Text("Open Website"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _brandPurple,
                        side: BorderSide(color: _brandPurple),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ]),
              ),
            ])),
      ]),
    );
  }
}

// --- FAVORITES SCREEN (Gradient Header) ---
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<Map<String, dynamic>>> _favs;
  final Color _brandPurple = const Color(0xff7b3df0);
  final Color _brandBlue = const Color(0xff5fc3ff);

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _favs = DatabaseHelper.instance.getFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Offline Favorites", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [_brandPurple, _brandBlue]),
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder(
        future: _favs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || (snapshot.data as List).isEmpty) return const Center(child: Text("No favorites yet."));
          final list = snapshot.data as List;
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              // Re-use the gradient card for consistency, even for offline items
              return _ArticleCard(item: item);
            },
          );
        },
      ),
    );
  }
}