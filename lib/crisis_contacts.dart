import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'app_config.dart';

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
          _ActionCrisisCard(title: "Emergency (999)", subtitle: "For life-threatening situations", phoneNumber: "999", icon: Icons.local_hospital, color: Color(0xFFB2EBF2), warning: "Only use for immediate danger."),
          _ActionCrisisCard(title: "DSA Helpline", subtitle: "TARUMT Student Affairs", phoneNumber: "01112345678", icon: Icons.support_agent, color: Color(0xFFB2DFDB), warning: "Available Mon-Fri, 9am - 5pm."),
          _ActionCrisisCard(title: "Befrienders KL", subtitle: "24/7 Emotional Support", phoneNumber: "0376272929", icon: Icons.favorite, color: Color(0xFFB3E5FC), warning: "Confidential and anonymous listening."),
        ],
      ),
    );
  }
}

class _FindHelpCard extends StatelessWidget {
  const _FindHelpCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFFEBEE), Color(0xFFFFCDD2)]), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))]),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => launchUrl(Uri.parse("https://www.google.com/maps/search/?api=1&query=hospital+near+me"), mode: LaunchMode.externalApplication),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(padding: const EdgeInsets.all(12), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.location_on, color: Colors.redAccent, size: 30)),
                const SizedBox(width: 16),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Find Nearest Hospital", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent)), Text("Locate medical help nearby", style: TextStyle(fontSize: 13, color: Colors.black54))])),
                const Icon(Icons.arrow_outward, color: Colors.redAccent),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionCrisisCard extends StatelessWidget {
  final String title, subtitle, phoneNumber, warning;
  final IconData icon;
  final Color color;
  const _ActionCrisisCard({required this.title, required this.subtitle, required this.phoneNumber, required this.warning, required this.icon, required this.color});

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(padding: const EdgeInsets.all(12), color: Colors.orange.shade50, child: Text(warning, style: TextStyle(color: Colors.orange.shade900))),
          const SizedBox(height: 20),
          ListTile(leading: const Icon(Icons.call, color: Colors.green), title: const Text("Call Now"), onTap: () { Navigator.pop(context); launchUrl(Uri(scheme: 'tel', path: phoneNumber)); }),
          ListTile(leading: const Icon(Icons.copy, color: Colors.blue), title: const Text("Copy Number"), onTap: () { Clipboard.setData(ClipboardData(text: phoneNumber)); Navigator.pop(context); }),
          ListTile(leading: const Icon(Icons.share, color: Colors.purple), title: const Text("Share Contact"), onTap: () { Share.share("Contact for $title: $phoneNumber"); Navigator.pop(context); }),
        ]));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showOptions(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20), height: 120, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
        child: Stack(children: [
          Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF006064))), Text(subtitle, style: const TextStyle(color: Color(0xFF004D40))), const SizedBox(height: 5), const Text("Tap for options", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))])),
          Positioned(right: 20, top: 25, child: Icon(icon, size: 70, color: Colors.white.withOpacity(0.6))),
        ]),
      ),
    );
  }
}