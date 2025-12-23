import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'app_config.dart';

class CrisisContactsScreen extends StatelessWidget {
  const CrisisContactsScreen({super.key});

  // Brand Colors
  final Color _brandPurple = const Color(0xff7b3df0);
  final Color _brandBlue = const Color(0xff5fc3ff);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB), // Matches app theme
      appBar: AppBar(
        title: const Text("Crisis Contacts", style: TextStyle(fontWeight: FontWeight.bold)),
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
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _FindHelpCard(),

          SizedBox(height: 10),

          _ActionCrisisCard(
            title: "Emergency (999)",
            subtitle: "For life-threatening situations",
            phoneNumber: "999",
            icon: Icons.local_hospital,
            warning: "Only use for immediate danger.",
            isEmergency: true, // Special Red Card
          ),

          _ActionCrisisCard(
            title: "DSA Helpline",
            subtitle: "TARUMT Student Affairs",
            phoneNumber: "01112345678",
            icon: Icons.support_agent,
            warning: "Available Mon-Fri, 9am - 5pm.",
          ),

          _ActionCrisisCard(
            title: "Befrienders KL",
            subtitle: "24/7 Emotional Support",
            phoneNumber: "0376272929",
            icon: Icons.favorite,
            warning: "Confidential and anonymous listening.",
          ),
        ],
      ),
    );
  }
}

// --- 1. FIND HOSPITAL CARD (Red Gradient for Urgency) ---
class _FindHelpCard extends StatelessWidget {
  const _FindHelpCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        // Red Gradient for Hospitals
        gradient: const LinearGradient(
          colors: [Color(0xFFFF512F), Color(0xFFDD2476)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF512F).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => launchUrl(
            Uri.parse("https://www.google.com/maps/search/?api=1&query=hospital+near+me"),
            mode: LaunchMode.externalApplication,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.location_on, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Find Nearest Hospital",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Locate medical help nearby",
                        style: TextStyle(fontSize: 13, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_outward, color: Colors.white70),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- 2. CONTACT CARDS (Matches MindTrack Style) ---
class _ActionCrisisCard extends StatelessWidget {
  final String title, subtitle, phoneNumber, warning;
  final IconData icon;
  final bool isEmergency;

  const _ActionCrisisCard({
    required this.title,
    required this.subtitle,
    required this.phoneNumber,
    required this.warning,
    required this.icon,
    this.isEmergency = false,
  });

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
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        warning,
                        style: TextStyle(color: Colors.orange.shade900, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.call, color: Colors.green),
                title: const Text("Call Now"),
                onTap: () {
                  Navigator.pop(context);
                  launchUrl(Uri(scheme: 'tel', path: phoneNumber));
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy, color: Colors.blue),
                title: const Text("Copy Number"),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: phoneNumber));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Number copied to clipboard")),
                  );
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
    // 999 gets a special gradient, others get the Brand Purple/Blue
    final gradient = isEmergency
        ? const LinearGradient(colors: [Color(0xFFEB3349), Color(0xFFF45C43)]) // Emergency Red
        : const LinearGradient(colors: [Color(0xff7b3df0), Color(0xff5fc3ff)]); // Brand Theme

    return GestureDetector(
      onTap: () => _showOptions(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: gradient,
          boxShadow: [
            BoxShadow(
              color: isEmergency ? Colors.red.withOpacity(0.3) : const Color(0xff7b3df0).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "Tap for options",
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}