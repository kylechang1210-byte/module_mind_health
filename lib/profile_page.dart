import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_config.dart';       // For isAdmin check
import 'auth_screens.dart';     // For LoginScreen redirect
import 'admin_dashboard.dart';  // For Admin Dashboard navigation

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Brand Colors
  final Color _brandPurple = const Color(0xff7b3df0);
  final Color _brandBlue = const Color(0xff5fc3ff);

  // --- FUNCTION: CHANGE PASSWORD (SUPABASE) ---
  void _showChangePasswordDialog(BuildContext context) {
    final passwordCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Change Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Enter your new password below:"),
            const SizedBox(height: 10),
            TextField(
              controller: passwordCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "New Password",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _brandPurple, foregroundColor: Colors.white),
            onPressed: () async {
              final newPass = passwordCtrl.text.trim();
              if (newPass.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password must be at least 6 characters")));
                return;
              }

              Navigator.pop(context); // Close dialog

              try {
                // UPDATE PASSWORD IN SUPABASE
                await Supabase.instance.client.auth.updateUser(
                  UserAttributes(password: newPass),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Password updated successfully!")),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e")),
                  );
                }
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? "Guest User";
    final String initial = email.isNotEmpty ? email[0].toUpperCase() : "G";

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- 1. GRADIENT HEADER SECTION ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_brandPurple, _brandBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: _brandPurple.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 4),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
                      ],
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: _brandPurple),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    email,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.4)),
                    ),
                    child: Text(
                      isAdmin ? "Administrator" : "Member",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            // --- 2. MENU OPTIONS ---
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // --- ADMIN SECTION ---
                  if (isAdmin) ...[
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 8, bottom: 10),
                        child: Text("Management", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    _ProfileMenuCard(
                      title: "Admin Dashboard",
                      subtitle: "Manage Users, Content & Tools",
                      icon: Icons.admin_panel_settings,
                      iconColor: Colors.orange,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboard())),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // --- GENERAL SETTINGS ---
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 8, bottom: 10),
                      child: Text("Account", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  // CHANGE PASSWORD (NOW WORKING)
                  _ProfileMenuCard(
                    title: "Change Password",
                    subtitle: "Update your security",
                    icon: Icons.lock_outline,
                    iconColor: _brandPurple,
                    onTap: () => _showChangePasswordDialog(context),
                  ),

                  // I DELETED "NOTIFICATIONS" TO AVOID CONFUSION

                  const SizedBox(height: 20),

                  // --- DANGER ZONE ---
                  _ProfileMenuCard(
                    title: "Sign Out",
                    subtitle: "Log out of your account",
                    icon: Icons.logout,
                    iconColor: Colors.redAccent,
                    isDestructive: true,
                    onTap: () async {
                      await Supabase.instance.client.auth.signOut();
                      if (context.mounted) {
                        Navigator.of(context, rootNavigator: true).pushReplacement(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 30),
                  const Text("Version 1.0.0", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- REUSABLE MENU CARD WIDGET ---
class _ProfileMenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ProfileMenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDestructive ? Colors.red : Colors.black87),
                      ),
                      const SizedBox(height: 2),
                      Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[300]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}