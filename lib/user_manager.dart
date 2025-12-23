import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// -----------------------------------------------------------------------------
// 1. DATA MODEL
// -----------------------------------------------------------------------------
class User {
  final String id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(), // Safely convert ID to string
      name: (json['name'] as String?) ?? 'Unknown User',
      email: (json['email'] as String?) ?? 'No Email',
    );
  }
}

// -----------------------------------------------------------------------------
// 2. MAIN WIDGET
// -----------------------------------------------------------------------------
class UserListTab extends StatefulWidget {
  const UserListTab({super.key});

  @override
  State<UserListTab> createState() => _UserListTabState();
}

class _UserListTabState extends State<UserListTab> {
  // --- Constants & Controllers ---
  final _supabase = Supabase.instance.client;
  final _searchCtrl = TextEditingController();
  static const Color _brandColor = Color(0xFF7555FF);

  // --- State Variables ---
  List<User> _allUsers = [];
  List<User> _filteredUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _searchCtrl.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // SUPABASE LOGIC
  // ---------------------------------------------------------------------------

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      debugPrint("Fetching users...");
      final data = await _supabase.from('user').select().order('id');

      final users = (data as List).map((e) => User.fromJson(e)).toList();

      if (mounted) {
        setState(() {
          _allUsers = users;
          _filteredUsers = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("ERROR FETCHING USERS: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error fetching users: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteUser(String id) async {
    try {
      await _supabase.from('user').delete().eq('id', id);
      _fetchUsers(); // Refresh list
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error deleting user: $e")),
        );
      }
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

  // ---------------------------------------------------------------------------
  // BOTTOM SHEET (EDIT FORM)
  // ---------------------------------------------------------------------------
  void _showUserForm(User user) {
    final nameCtrl = TextEditingController(text: user.name);
    final emailCtrl = TextEditingController(text: user.email);
    final passCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 25,
          right: 25,
          top: 25,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            const Text(
              "Edit User",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _brandColor,
              ),
            ),
            const SizedBox(height: 20),

            // Fields
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Full Name"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: "Email Address"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passCtrl,
              decoration: const InputDecoration(
                labelText: "New Password (Optional)",
                hintText: "Leave blank to keep current",
              ),
            ),

            // Save Button
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brandColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  Navigator.pop(ctx); // Close sheet
                  try {
                    final updates = {
                      'name': nameCtrl.text.trim(),
                      'email': emailCtrl.text.trim(),
                    };
                    if (passCtrl.text.isNotEmpty) {
                      updates['password'] = passCtrl.text.trim();
                    }

                    await _supabase
                        .from('user')
                        .update(updates)
                        .eq('id', user.id);

                    _fetchUsers(); // Refresh data
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error updating: $e")),
                      );
                    }
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

  // ---------------------------------------------------------------------------
  // MAIN UI BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Search Bar
        _buildSearchBar(),

        // 2. User List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredUsers.isEmpty
              ? const Center(child: Text("No users found."))
              : _buildUserList(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: _searchCtrl,
        decoration: InputDecoration(
          hintText: "Search users...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildUserList() {
    return ListView.builder(
      itemCount: _filteredUsers.length,
      itemBuilder: (context, index) {
        final user = _filteredUsers[index];
        return _UserCard(
          user: user,
          brandColor: _brandColor,
          onEdit: () => _showUserForm(user),
          onDelete: () => _deleteUser(user.id),
        );
      },
    );
  }
}


class _UserCard extends StatelessWidget {
  final User user;
  final Color brandColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _UserCard({
    required this.user,
    required this.brandColor,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        // Avatar
        leading: CircleAvatar(
          backgroundColor: brandColor.withValues(alpha: 0.1),
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
            style: TextStyle(
              color: brandColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Info
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(user.email),
        // Actions
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
              tooltip: 'Edit User',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
              tooltip: 'Delete User',
            ),
          ],
        ),
      ),
    );
  }
}