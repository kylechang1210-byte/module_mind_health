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

// 2. THE USER LIST PAGE
class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final supabase = Supabase.instance.client;

  // Controllers
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _newPassCtrl = TextEditingController();

  List<User> _allUsers = [];
  List<User> _filteredUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _newPassCtrl.dispose();
    super.dispose();
  }

  // --- FETCH USERS ---
  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final response = await supabase
          .from('user')
          .select()
          .order('id', ascending: true);

      final users = (response as List)
          .map((item) => User.fromJson(item))
          .toList();

      if (mounted) {
        setState(() {
          _allUsers = users;
          _filteredUsers = users;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- SEARCH LOGIC ---
  void _onSearchChanged() {
    final query = _searchCtrl.text.toLowerCase();
    setState(() {
      _filteredUsers = _allUsers.where((u) {
        return u.name.toLowerCase().contains(query) ||
            u.email.toLowerCase().contains(query);
      }).toList();
    });
  }

  // --- DELETE USER LOGIC (NEW) ---
  Future<void> _deleteUser(String userId) async {
    // 1. Ask for confirmation
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete User?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Cancel
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // Confirm
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return; // Stop if they clicked Cancel

    // 2. Perform Delete
    try {
      setState(() => _isLoading = true);

      // A. Delete from Database Table ('user') - Removes from list
      await supabase.from('user').delete().eq('id', userId);

      // B. (Optional) Delete from Authentication - Prevents login
      // Note: This might fail if you are not a Super Admin, but we try anyway.
      try {
        await supabase.auth.admin.deleteUser(userId);
      } catch (e) {
        print("Could not delete from Auth (Permissions issue): $e");
      }

      // 3. Refresh List
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User deleted successfully")),
        );
        _fetchUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error deleting: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- UPDATE USER LOGIC ---
  Future<void> _updateUser(String userId) async {
    final String name = _nameCtrl.text.trim();
    final String email = _emailCtrl.text.trim();
    final String newPassword = _newPassCtrl.text.trim();

    if (name.isEmpty || email.isEmpty) return;

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()));

    try {
      if (newPassword.isNotEmpty) {
        await supabase.auth.admin.updateUserById(
          userId,
          attributes: AdminUserAttributes(password: newPassword),
        );
      }

      await supabase.from('user').update({
        'name': name,
        'email': email,
      }).eq('id', userId);

      if (mounted) {
        Navigator.pop(context); // Pop loading
        Navigator.pop(context); // Pop edit dialog
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("User Updated!"),
          backgroundColor: Colors.green,
        ));
        _fetchUsers();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
      }
    }
  }

  // --- EDIT DIALOG ---
  void _showEditDialog(User user) {
    _nameCtrl.text = user.name;
    _emailCtrl.text = user.email;
    _newPassCtrl.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit ${user.name}"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: "Name", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  children: [
                    const Row(children: [
                      Icon(Icons.lock_reset, color: Colors.orange),
                      SizedBox(width: 8),
                      Text("Force Password Reset", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange))
                    ]),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _newPassCtrl,
                      decoration: const InputDecoration(
                        labelText: "New Password",
                        helperText: "Leave empty to keep current",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => _updateUser(user.id),
            child: const Text("Save Changes"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Users")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: "Search Users...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
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
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal.shade100,
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                      ),
                    ),
                    title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(user.email),

                    // --- UPDATED BUTTONS ROW ---
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min, // shrink to fit buttons
                      children: [
                        // Edit Button
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showEditDialog(user),
                        ),
                        // Delete Button (NEW)
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteUser(user.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}