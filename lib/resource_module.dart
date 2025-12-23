import 'dart:math';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:module_mind_health/therapy_dashboard.dart';
import 'package:module_mind_health/healing_music.dart';
import 'package:module_mind_health/breathing.dart';

// Imports for the other pages
import 'crisis_contacts.dart';
import 'education_content.dart';

// ===============================================================
// 1. RESOURCE HUB SCREEN (Main Menu)
// ===============================================================
class ResourceHubScreen extends StatelessWidget {
  const ResourceHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f6fb),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 20),
            const Text(
              'Resource Hub',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xff7b3df0),
              ),
            ),
            const SizedBox(height: 24),

            // --- 1. THE WELLNESS LAB ---
            _ResourceCard(
              title: 'Wellness\nLab',
              icon: Icons.science_outlined,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WellnessLabScreen())),
            ),
            const SizedBox(height: 16),

            // --- 2. HEALTH AWARENESS (New Grid Design) ---
            _ResourceCard(
              title: 'Health\nAwareness',
              icon: Icons.health_and_safety_outlined,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthAwarenessScreen())),
            ),
            const SizedBox(height: 16),

            // --- 3. CRISIS CONTACTS ---
            _ResourceCard(
              title: 'Crisis\nContacts',
              icon: Icons.phone_in_talk,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CrisisContactsScreen())),
            ),
            const SizedBox(height: 16),

            // --- 4. EDUCATIONAL CONTENT ---
            _ResourceCard(
              title: 'Educational\nContent',
              icon: Icons.menu_book,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EducationContentScreen())),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ResourceCard({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xff7b3df0), Color(0xff5fc3ff)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff7b3df0).withValues(alpha:0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, height: 1.1),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha:0.2), shape: BoxShape.circle),
              child: Icon(icon, size: 32, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================================================
// 2. HEALTH AWARENESS SCREEN (Redesigned as Grid)
// ===============================================================

class AwarenessItem {
  final String title;
  final String category;
  final String description;
  final String url;
  final IconData icon;

  AwarenessItem({
    required this.title,
    required this.category,
    required this.description,
    required this.url,
    required this.icon,
  });
}

class HealthAwarenessScreen extends StatefulWidget {
  const HealthAwarenessScreen({super.key});

  @override
  State<HealthAwarenessScreen> createState() => _HealthAwarenessScreenState();
}

class _HealthAwarenessScreenState extends State<HealthAwarenessScreen> {
  final Color _brandPurple = const Color(0xff7b3df0);
  final Color _brandBlue = const Color(0xff5fc3ff);

  final List<AwarenessItem> _allTools = [
    AwarenessItem(
      title: "Self-Check",
      category: "Screening",
      description: "DASS-21 Test",
      url: "https://www.psycom.net/depression-test",
      icon: Icons.assignment_ind,
    ),
    AwarenessItem(
      title: "Burnout Signs",
      category: "Symptoms",
      description: "Am I just tired?",
      url: "https://www.helpguide.org/articles/stress/burnout-prevention-and-recovery.htm",
      icon: Icons.battery_alert,
    ),
    AwarenessItem(
      title: "Sleep Health",
      category: "Wellness",
      description: "Fix your schedule",
      url: "https://www.sleepfoundation.org/sleep-hygiene",
      icon: Icons.bedtime,
    ),
    AwarenessItem(
      title: "Anxiety Info",
      category: "Info",
      description: "Know the signs",
      url: "https://www.nimh.nih.gov/health/topics/anxiety-disorders",
      icon: Icons.psychology,
    ),
    AwarenessItem(
      title: "Seek Help?",
      category: "Guide",
      description: "When to act",
      url: "https://www.mentalhealth.gov/talk/people-mental-health-problems",
      icon: Icons.help_outline,
    ),
    AwarenessItem(
      title: "Mindfulness",
      category: "Wellness",
      description: "The basics",
      url: "https://www.mindful.org/what-is-mindfulness/",
      icon: Icons.self_improvement,
    ),
  ];

  List<AwarenessItem> _filteredTools = [];
  String _selectedCategory = "All";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredTools = _allTools;
  }

  void _runFilter() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTools = _allTools.where((item) {
        bool matchesCategory = _selectedCategory == "All" || item.category == _selectedCategory;
        bool matchesSearch = item.title.toLowerCase().contains(query);
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  void _changeCategory(String category) {
    setState(() => _selectedCategory = category);
    _runFilter();
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not open link")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ["All", ..._allTools.map((e) => e.category).toSet()];

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      appBar: AppBar(
        title: const Text("Health Awareness", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [_brandPurple, _brandBlue]),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // --- SEARCH BAR (Gradient) ---
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_brandPurple, _brandBlue],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _runFilter(),
              decoration: InputDecoration(
                hintText: "Search topics...",
                prefixIcon: Icon(Icons.search, color: _brandPurple),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // --- FILTER CHIPS ---
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Row(
              children: categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (bool selected) => _changeCategory(cat),
                    backgroundColor: Colors.white,
                    selectedColor: _brandPurple.withValues(alpha:0.15),
                    labelStyle: TextStyle(
                      color: isSelected ? _brandPurple : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? _brandPurple : Colors.grey.shade300,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
          ),

          // --- GRID CONTENT (The New Design) ---
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1, // Slightly taller cards
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _filteredTools.length,
              itemBuilder: (context, index) {
                final item = _filteredTools[index];
                return _buildGridCard(item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridCard(AwarenessItem item) {
    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _launchURL(item.url),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Bubble
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _brandPurple.withValues(alpha:0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, size: 30, color: _brandPurple),
              ),
              const SizedBox(height: 12),
              // Title
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Description
              Text(
                item.description,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===============================================================
// 3. THE WELLNESS LAB (Keep Existing Logic)
// ===============================================================

class WellnessLabScreen extends StatefulWidget {
  const WellnessLabScreen({super.key});

  @override
  State<WellnessLabScreen> createState() => _WellnessLabScreenState();
}

class _WellnessLabScreenState extends State<WellnessLabScreen> {
  final Color _brandPurple = const Color(0xff7b3df0);
  final Color _brandBlue = const Color(0xff5fc3ff);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      appBar: AppBar(
        title: const Text("Wellness Lab", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [_brandPurple, _brandBlue]),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _SectionHeader(title: "Symptom Decoder", subtitle: "What is your body telling you?"),
          SizedBox(height: 12),
          _SymptomDecoderWidget(),
          SizedBox(height: 30),
          _SectionHeader(title: "Mental Battery", subtitle: "Check your current energy level."),
          SizedBox(height: 12),
          _MentalBatteryWidget(),
          SizedBox(height: 30),
          _SectionHeader(title: "Myth vs. Fact", subtitle: "Tap the card to reveal the truth."),
          SizedBox(height: 12),
          _MythBusterWidget(),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title, subtitle;
  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xff7b3df0))),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
      ],
    );
  }
}

// ----------------------------------------------------------------
// FEATURE 1: SYMPTOM DECODER
// ----------------------------------------------------------------
class _SymptomDecoderWidget extends StatelessWidget {
  const _SymptomDecoderWidget();

  final List<Map<String, dynamic>> symptoms = const [
    {"label": "Racing Heart", "icon": Icons.favorite_border, "cause": "Anxiety Spike", "desc": "Your body is in 'Fight or Flight' mode.", "tool": "Try Breathing", "page": BreathingPage()},
    {"label": "Brain Fog", "icon": Icons.cloud_outlined, "cause": "Overwhelm", "desc": "Your brain is tired of processing input.", "tool": "Try Music", "page": HealingMusicPage()},
    {"label": "Tension", "icon": Icons.accessibility_new, "cause": "Chronic Stress", "desc": "We hold stress in our shoulders/jaw.", "tool": "Move Body", "page": TherapyDashboard()},
    {"label": "Insomnia", "icon": Icons.bedtime, "cause": "Racing Mind", "desc": "Your brain hasn't received a 'safe' signal.", "tool": "Sleep Sounds", "page": HealingMusicPage()},
  ];

  void _showDetail(BuildContext context, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xff7b3df0).withValues(alpha:0.1), shape: BoxShape.circle),
              child: Icon(data['icon'], size: 40, color: const Color(0xff7b3df0)),
            ),
            const SizedBox(height: 20),
            Text(data['label'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Potential Cause: ${data['cause']}", style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text(data['desc'], textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, height: 1.5)),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff7b3df0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                icon: const Icon(Icons.arrow_forward),
                label: Text(data['tool']),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => data['page']));
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: symptoms.length,
      itemBuilder: (context, index) {
        final s = symptoms[index];
        return Material(
          color: Colors.white,
          elevation: 2,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showDetail(context, s),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(s['icon'] as IconData, color: const Color(0xff7b3df0), size: 28),
                const SizedBox(height: 8),
                Text(s['label'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ----------------------------------------------------------------
// FEATURE 2: MENTAL BATTERY CHECK
// ----------------------------------------------------------------
class _MentalBatteryWidget extends StatefulWidget {
  const _MentalBatteryWidget();

  @override
  State<_MentalBatteryWidget> createState() => _MentalBatteryWidgetState();
}

class _MentalBatteryWidgetState extends State<_MentalBatteryWidget> {
  double _batteryLevel = 50;

  Color _getColor() {
    if (_batteryLevel > 70) return Colors.green;
    if (_batteryLevel > 30) return Colors.orange;
    return Colors.red;
  }

  String _getMessage() {
    if (_batteryLevel > 70) return "You're fully charged! Tackle something big.";
    if (_batteryLevel > 30) return "Running average. Pace yourself.";
    return "Low energy. Please stop and breathe.";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Energy Level", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("${_batteryLevel.toInt()}%", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _getColor())),
            ],
          ),
          const SizedBox(height: 10),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _getColor(),
              inactiveTrackColor: Colors.grey[200],
              thumbColor: _getColor(),
              overlayColor: _getColor().withValues(alpha:0.2),
              trackHeight: 12,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            ),
            child: Slider(
              value: _batteryLevel,
              min: 0,
              max: 100,
              onChanged: (val) => setState(() => _batteryLevel = val),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getColor().withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: _getColor(), size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(_getMessage(), style: TextStyle(color: _getColor(), fontWeight: FontWeight.bold, fontSize: 13))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------
// FEATURE 3: MYTH BUSTER (3D Flip Animation)
// ----------------------------------------------------------------
class _MythBusterWidget extends StatefulWidget {
  const _MythBusterWidget();

  @override
  State<_MythBusterWidget> createState() => _MythBusterWidgetState();
}

class _MythBusterWidgetState extends State<_MythBusterWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack));
  }

  void _flipCard() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    _isFront = !_isFront;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * pi;
          final isBack = angle >= pi / 2;
          final matrix = Matrix4.identity()
            ..setEntry(3, 2, 0.001) // Perspective
            ..rotateY(angle);

          return Transform(
            transform: matrix,
            alignment: Alignment.center,
            child: isBack
                ? Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..rotateY(pi), // Correct text mirroring
              child: _buildBackCard(),
            )
                : _buildFrontCard(),
          );
        },
      ),
    );
  }

  // --- FRONT SIDE (MYTH) ---
  Widget _buildFrontCard() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)]), // Dark Purple Gradient
        boxShadow: [BoxShadow(color: Colors.purple.withValues(alpha:0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Stack(
        children: [
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("MYTH", style: TextStyle(color: Colors.white70, letterSpacing: 2, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text(
                    "\"It's all in your head.\nJust calm down.\"",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),
          Positioned(bottom: 15, right: 15, child: Icon(Icons.touch_app, color: Colors.white.withValues(alpha:0.5))),
        ],
      ),
    );
  }

  // --- BACK SIDE (FACT) ---
  Widget _buildBackCard() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        border: Border.all(color: const Color(0xff7b3df0), width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.1), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("FACT", style: TextStyle(color: Color(0xff7b3df0), letterSpacing: 2, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text(
                "Anxiety is a physiological response involving cortisol & adrenaline. It is real, not imagined.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black87, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}