import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 1. MODEL CLASS
class User {
  final String id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['name'] as String? ?? 'No Name',
      email: json['email'] as String? ?? 'No Email',
    );
  }
}

// 2. THE USER LIST WIDGET
class UserListTab extends StatefulWidget {
  const UserListTab({super.key});

  @override
  State<UserListTab> createState() => _UserListTabState();
}

class _UserListTabState extends State<UserListTab> {
  final supabase = Supabase.instance.client;
  final TextEditingController _searchCtrl = TextEditingController();
  final Color _brandColor = const Color(0xFF7555FF); // Brand Color

  List<User> _allUsers = [];
  List<User> _filteredUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _searchCtrl.addListener(_filterUsers);
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final data = await supabase.from('user').select().order('id');
      final users = (data as List).map((e) => User.fromJson(e)).toList();

      setState(() {
        _allUsers = users;
        _filteredUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterUsers() {
    final query = _searchCtrl.text.toLowerCase();
    setState(() {
      _filteredUsers = _allUsers.where((u) {
        return u.name.toLowerCase().contains(query) ||
            u.email.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _deleteUser(String id) async {
    try {
      await supabase.from('user').delete().eq('id', id);
      _fetchUsers();
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // --- UNIFIED BOTTOM SHEET UI FOR EDITING ---
  void _showUserForm(User user) {
    final nameCtrl = TextEditingController(text: user.name);
    final emailCtrl = TextEditingController(text: user.email);
    final passCtrl = TextEditingController(); // Optional new password

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 25, right: 25, top: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Edit User", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _brandColor)),
            const SizedBox(height: 20),

            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Full Name")),
            const SizedBox(height: 10),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: "Email Address")),
            const SizedBox(height: 10),
            TextField(controller: passCtrl, decoration: const InputDecoration(labelText: "New Password (Optional)", hintText: "Leave blank to keep current")),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: _brandColor, foregroundColor: Colors.white),
                onPressed: () async {
                  Navigator.pop(ctx);
                  try {
                    final updates = {'name': nameCtrl.text.trim(), 'email': emailCtrl.text.trim()};
                    if (passCtrl.text.isNotEmpty) updates['password'] = passCtrl.text.trim();

                    await supabase.from('user').update(updates).eq('id', user.id);
                    _fetchUsers();
                  } catch (e) {
                    if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                  }
                },
                child: const Text("SAVE CHANGES"),
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: "Search users...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0), // Fixes internal height gap
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
            ),
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredUsers.isEmpty
              ? const Center(child: Text("No users found."))
              : ListView.builder(
            itemCount: _filteredUsers.length,
            itemBuilder: (context, index) {
              final user = _filteredUsers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _brandColor.withOpacity(0.1),
                    child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?', style: TextStyle(color: _brandColor, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(user.email),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showUserForm(user)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteUser(user.id)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}