import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_config.dart';
import 'auth_screens.dart'; // For LoginScreen redirect
import 'crisis_contacts.dart';
import 'education_content.dart';
import 'user_manager.dart'; // Your existing file
import 'admin_articles.dart'; // Your existing file
import 'resource_module.dart';

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
              Text(
                email,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text("Welcome back!", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              const Divider(),
              if (isAdmin) ...[
                ListTile(
                  leading: const Icon(Icons.people, color: Colors.orange),
                  title: const Text("Manage Users (Admin)"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UserListPage()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.article, color: Colors.orange),
                  title: const Text("Manage Articles (Admin)"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminArticleManager(),
                      ),
                    );
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
                  if (context.mounted)
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
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
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
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
                title: "Knowledge Base",
                icon: Icons.lightbulb_outline,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResourceScreen()))
            ),
            _buildMenuButton(
              context,
              title: "Crisis Contacts",
              icon: Icons.phone_in_talk,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CrisisContactsScreen()),
              ),
            ),
            _buildMenuButton(
              context,
              title: "Education Content",
              icon: Icons.menu_book,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EducationContentScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
