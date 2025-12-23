import 'package:flutter/material.dart';
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

            // --- 1. SYMPTOM DECODER (Promoted to Main Feature) ---
            _ResourceCard(
              title: 'Symptom\nDecoder',
              icon: Icons.accessibility_new_rounded,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SymptomDecoderScreen())),
            ),
            const SizedBox(height: 16),

            // --- 2. CRISIS CONTACTS ---
            _ResourceCard(
              title: 'Crisis\nContacts',
              icon: Icons.phone_in_talk,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CrisisContactsScreen())),
            ),
            const SizedBox(height: 16),

            // --- 3. EDUCATIONAL CONTENT ---
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

// --- STANDARD MENU CARD ---
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
              color: const Color(0xff7b3df0).withValues(alpha: 0.3),
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
// 2. SYMPTOM DECODER SCREEN (Standalone Feature)
// ===============================================================

class SymptomDecoderScreen extends StatelessWidget {
  const SymptomDecoderScreen({super.key});

  final Color _brandPurple = const Color(0xff7b3df0);
  final Color _brandBlue = const Color(0xff5fc3ff);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      appBar: AppBar(
        title: const Text("Symptom Decoder", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [_brandPurple, _brandBlue]),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Text
            const Text(
              "What are you feeling?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              "Tap a physical symptom to understand its mental link and find a quick solution.",
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 24),

            // The Grid of Symptoms
            const _SymptomGrid(),
          ],
        ),
      ),
    );
  }
}

class _SymptomGrid extends StatelessWidget {
  const _SymptomGrid();

  final List<Map<String, dynamic>> symptoms = const [
    {
      "label": "Racing Heart",
      "icon": Icons.favorite_border,
      "cause": "Anxiety Spike",
      "desc": "Your body is in 'Fight or Flight' mode. You need to slow your heart rate down manually.",
      "tool": "Start Breathing",
      "page": BreathingPage()
    },
    {
      "label": "Brain Fog",
      "icon": Icons.cloud_outlined,
      "cause": "Overwhelm",
      "desc": "Your brain is tired of processing input. It needs a gentle, rhythmic reset.",
      "tool": "Play Healing Music",
      "page": HealingMusicPage()
    },
    {
      "label": "Muscle Tension",
      "icon": Icons.accessibility_new,
      "cause": "Chronic Stress",
      "desc": "We unconsciously hold stress in our shoulders and jaw. Movement releases this.",
      "tool": "Move Your Body",
      "page": TherapyDashboard()
    },
    {
      "label": "Can't Sleep",
      "icon": Icons.bedtime,
      "cause": "Racing Mind",
      "desc": "Your brain hasn't received a 'safety' signal to shut down for the night.",
      "tool": "Sleep Sounds",
      "page": HealingMusicPage()
    },
    {
      "label": "Shallow Breath",
      "icon": Icons.air,
      "cause": "Panic / Fear",
      "desc": "Short breaths decrease oxygen and increase panic. Deep breaths reverse this instantly.",
      "tool": "Deep Breathing",
      "page": BreathingPage()
    },
    {
      "label": "Restlessness",
      "icon": Icons.directions_run,
      "cause": "Adrenaline",
      "desc": "You have excess energy from stress. Burn it off with light exercise.",
      "tool": "Exercise Tools",
      "page": TherapyDashboard()
    },
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
        childAspectRatio: 1.3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: symptoms.length,
      itemBuilder: (context, index) {
        final s = symptoms[index];
        return Material(
          color: Colors.white,
          elevation: 2,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _showDetail(context, s),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(s['icon'] as IconData, color: const Color(0xff7b3df0), size: 32),
                const SizedBox(height: 12),
                Text(s['label'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
        );
      },
    );
  }
}