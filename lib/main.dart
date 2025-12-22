import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- CUSTOM IMPORTS (Make sure these files exist in your lib folder) ---
import 'database_helper.dart';
import 'user_manager.dart';
import 'admin_articles.dart';
import 'forgot_password.dart';

// ============================================================================
// 1. CONFIGURATION
// ============================================================================

const supabaseUrl = 'https://fkjjrvrffecgctsgaeqv.supabase.co';
const supabaseKey = 'sb_publishable_BzAGzgIfBOScyCdq5xNioA_8lTXMTK8';

bool isAdmin = false;

// --- THEME COLORS (Friend's Blue Theme) ---
const Color kPrimaryBlue = Color(0xFF5C9DFF);    // Sky Blue
const Color kBackgroundBlue = Color(0xFFF5F7FA); // Cloud White
const Color kLightBlueIconBg = Color(0xFFE3F2FD); // Pale Blue for Icons

// ============================================================================
// 2. MAIN APP SETUP
// ============================================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  runApp(const MindHealthApp());
}

class MindHealthApp extends StatelessWidget {
  const MindHealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mind Health',
      // 🎨 GLOBAL BLUE THEME APPLIED
      theme: ThemeData(
        primaryColor: kPrimaryBlue,
        scaffoldBackgroundColor: kBackgroundBlue,
        appBarTheme: const AppBarTheme(
          backgroundColor: kPrimaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryBlue,
          primary: kPrimaryBlue,
          secondary: const Color(0xFF82B1FF),
        ),
        useMaterial3: true,
        // Input Fields Style
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIconColor: kPrimaryBlue,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kPrimaryBlue, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        // Buttons Style
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: kPrimaryBlue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

// ============================================================================
// 3. AUTH GATE (Login Check)
// ============================================================================
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAuth());
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 100));
    final session = Supabase.instance.client.auth.currentSession;

    if (!mounted) return;

    if (session != null) {
      // 🔒 ADMIN CHECK LOGIC
      // 1. Check Hardcoded List
      final List<String> adminEmails = ["gary@gmail.com", "gary.lum12@gmail.com"];
      bool isHardcodedAdmin = session.user.email != null && adminEmails.contains(session.user.email);

      // 2. (Optional) Check Database Role
      bool isDbAdmin = false;
      try {
        final data = await Supabase.instance.client
            .from('user')
            .select('role')
            .eq('email', session.user.email!)
            .maybeSingle(); // Use maybeSingle to avoid crash if user not found
        if (data != null && data['role'] == 'admin') {
          isDbAdmin = true;
        }
      } catch (e) {
        // Ignore DB error, fallback to hardcoded
      }

      // Final Decision
      isAdmin = isHardcodedAdmin || isDbAdmin;

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ResourceHubScreen()),
        );
      }
    } else {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

// ============================================================================
// 4. LOGIN SCREEN
// ============================================================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthGate()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.spa, size: 80, color: kPrimaryBlue),
            const SizedBox(height: 20),
            const Text(
              "Welcome Back",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: kPrimaryBlue,
              ),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                  );
                },
                child: const Text(
                  "Forgot Password?",
                  style: TextStyle(fontWeight: FontWeight.bold, color: kPrimaryBlue),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isLoading ? null : _login,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Login"),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SignUpScreen()),
              ),
              child: const Text("Don't have an account? Sign Up", style: TextStyle(color: kPrimaryBlue)),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 5. SIGN UP SCREEN
// ============================================================================
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _signUp() async {
    if (_nameCtrl.text.isEmpty || _emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );

      if (response.user != null) {
        await Supabase.instance.client.from('user').insert({
          'name': _nameCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Account created! Please Login.")),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Create Account")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Icon(Icons.person_add, size: 80, color: kPrimaryBlue),
              const SizedBox(height: 20),
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: "Username",
                  prefixIcon: Icon(Icons.badge),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _signUp,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Sign Up"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 6. RESOURCE HUB (White Cards & Blue Icons)
// ============================================================================
class ResourceHubScreen extends StatelessWidget {
  const ResourceHubScreen({super.key});

  void _showProfileMenu(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? "User";

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_circle, size: 60, color: kPrimaryBlue),
              const SizedBox(height: 10),
              Text(email, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Text("Welcome back!", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              const Divider(),

              if (isAdmin) ...[
                ListTile(
                  leading: const Icon(Icons.people, color: Colors.orange),
                  title: const Text("Manage Users (Admin)"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const UserListPage()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.article, color: Colors.orange),
                  title: const Text("Manage Articles (Admin)"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminArticleManager()));
                  },
                ),
                const Divider(),
              ],

              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text("Sign Out"),
                onTap: () async {
                  Navigator.pop(context);
                  await Supabase.instance.client.auth.signOut();
                  if (context.mounted) {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 🎨 BUTTON HELPER (White Card Style)
  Widget _buildMenuButton(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.blue.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: kLightBlueIconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 32, color: kPrimaryBlue),
                ),
                const SizedBox(width: 24),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Resource Hub"),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 30),
            onPressed: () => _showProfileMenu(context),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildMenuButton(
              context,
              title: "Crisis Contacts",
              icon: Icons.phone_in_talk,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CrisisContactsScreen())),
            ),
            _buildMenuButton(
              context,
              title: "Education Content",
              icon: Icons.menu_book,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EducationContentScreen())),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 7. EDUCATIONAL CONTENT (White Cards List)
// ============================================================================
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
      backgroundColor: kBackgroundBlue,
      appBar: AppBar(
        title: const Text("Educational Content"),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavoritesScreen()),
            ),
          ),
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

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

              // --- FIX: RESTORED IMAGE LOGIC HERE ---
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: kLightBlueIconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: item['image'] != null && item['image'].toString().isNotEmpty
                      ? Image.network(
                    item['image'],
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => const Icon(Icons.article, color: kPrimaryBlue),
                  )
                      : const Icon(Icons.article, color: kPrimaryBlue),
                ),
              ),
              // -------------------------------------

              title: Text(
                item['title'] ?? 'No Title',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              subtitle: Text(
                item['subtitle'] ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ArticleDetailScreen(data: item),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// 8. ARTICLE DETAIL SCREEN
// ============================================================================
class ArticleDetailScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final int readTime;

  ArticleDetailScreen({super.key, required this.data, int? readTime})
      : readTime = readTime ?? (data['fullContent'].toString().split(' ').length / 50).ceil();

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
    int wordCount = content.split(' ').length;
    int estimatedTime = (wordCount / 50).ceil();
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
        setState(() => _remainingSeconds--);
      } else {
        _timer.cancel();
        setState(() => _isTimerRunning = false);
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
    final String image = widget.data['image'] ?? "https://placehold.co/600x400";
    final String content = widget.data['full_content'] ?? widget.data['fullContent'] ?? "No content available.";
    final String url = widget.data['url'] ?? "https://google.com";

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            backgroundColor: kPrimaryBlue,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: "img_${widget.data['id']}",
                child: Image.network(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    color: Colors.grey,
                    child: const Icon(Icons.broken_image, size: 50),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => Share.share("Read '$title': $url"),
                icon: const Icon(Icons.share, color: Colors.white),
              ),
              IconButton(
                onPressed: _toggleFavorite,
                icon: Icon(
                  isSaved ? Icons.favorite : Icons.favorite_border,
                  color: isSaved ? Colors.red : Colors.white,
                ),
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _isTimerRunning ? Colors.orange.shade50 : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isTimerRunning ? Colors.orange.shade200 : Colors.green.shade200,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isTimerRunning ? Icons.timer : Icons.check_circle,
                            size: 18,
                            color: _isTimerRunning ? Colors.orange.shade800 : Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isTimerRunning
                                ? "${(_remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(_remainingSeconds % 60).toString().padLeft(2, '0')} left"
                                : "Goal Completed!",
                            style: TextStyle(
                              color: _isTimerRunning ? Colors.orange.shade900 : Colors.green.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF004D40),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      content,
                      style: TextStyle(fontSize: 16, height: 1.8, color: Colors.grey.shade800),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final Uri uri = Uri.parse(url);
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        },
                        icon: const Icon(Icons.public, size: 18),
                        label: const Text("Open Website"),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 9. FAVORITES SCREEN
// ============================================================================
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<Map<String, dynamic>>> _favs;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    final futureData = DatabaseHelper.instance.getFavorites();
    setState(() {
      _favs = futureData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Offline Favorites")),
      body: FutureBuilder(
        future: _favs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
            return const Center(child: Text("No favorites yet."));
          }

          final list = snapshot.data as List;

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return ListTile(
                leading: Image.network(item['image'], width: 50, fit: BoxFit.cover),
                title: Text(item['title']),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await DatabaseHelper.instance.removeFavorite(item['id']);
                    _refresh();
                  },
                ),
                onTap: () {
                  final data = Map<String, dynamic>.from(item);
                  if (item['colorValue'] != null) {
                    data['color'] = Color(item['colorValue']);
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ArticleDetailScreen(data: data)),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// ============================================================================
// 10. CRISIS CONTACTS SCREEN
// ============================================================================
class CrisisContactsScreen extends StatelessWidget {
  const CrisisContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundBlue,
      appBar: AppBar(title: const Text("Crisis Contacts")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _FindHelpCard(),
          _ActionCrisisCard(
            title: "Emergency (999)",
            subtitle: "For life-threatening situations",
            phoneNumber: "999",
            icon: Icons.local_hospital,
            color: Color(0xFFB2EBF2),
            warning: "Only use for immediate danger.",
          ),
          _ActionCrisisCard(
            title: "DSA Helpline",
            subtitle: "TARUMT Student Affairs",
            phoneNumber: "01112345678",
            icon: Icons.support_agent,
            color: Color(0xFFB2DFDB),
            warning: "Available Mon-Fri, 9am - 5pm.",
          ),
          _ActionCrisisCard(
            title: "Befrienders KL",
            subtitle: "24/7 Emotional Support",
            phoneNumber: "0376272929",
            icon: Icons.favorite,
            color: Color(0xFFB3E5FC),
            warning: "Confidential and anonymous listening.",
          ),
        ],
      ),
    );
  }
}

// --- HELPER 1: GOOGLE MAPS CARD ---
class _FindHelpCard extends StatelessWidget {
  const _FindHelpCard();

  Future<void> _openMap(BuildContext context) async {
    final Uri googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=hospital+near+me");
    try {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error launching map: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFFEBEE), Color(0xFFFFCDD2)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.red.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _openMap(context),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.location_on, color: Colors.redAccent, size: 30),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Find Nearest Hospital",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent),
                      ),
                      Text("Locate medical help nearby", style: TextStyle(fontSize: 13, color: Colors.black54)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_outward, color: Colors.redAccent),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- HELPER 2: ACTION BUTTON CARD ---
class _ActionCrisisCard extends StatelessWidget {
  final String title, subtitle, phoneNumber, warning;
  final IconData icon;
  final Color color;

  const _ActionCrisisCard({
    required this.title,
    required this.subtitle,
    required this.phoneNumber,
    required this.warning,
    required this.icon,
    required this.color,
  });

  Future<void> _makeCall() async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) await launchUrl(launchUri);
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.orange.shade50,
                child: Text(warning, style: TextStyle(color: Colors.orange.shade900)),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.call, color: Colors.green),
                title: const Text("Call Now"),
                onTap: () { Navigator.pop(context); _makeCall(); },
              ),
              ListTile(
                leading: const Icon(Icons.copy, color: Colors.blue),
                title: const Text("Copy Number"),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: phoneNumber));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Colors.purple),
                title: const Text("Share Contact"),
                onTap: () {
                  Share.share("Contact for $title: $phoneNumber");
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showOptions(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        height: 120,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF006064)),
                  ),
                  Text(subtitle, style: const TextStyle(color: Color(0xFF004D40))),
                  const SizedBox(height: 5),
                  const Text("Tap for options", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Positioned(
              right: 20,
              top: 25,
              child: Icon(icon, size: 70, color: Colors.white.withOpacity(0.6)),
            ),
          ],
        ),
      ),
    );
  }
}