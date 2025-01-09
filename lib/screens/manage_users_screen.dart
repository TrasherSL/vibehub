import 'package:flutter/material.dart';
import '../models/vibehub_user.dart';
import '../services/user_service.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({Key? key}) : super(key: key);

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final UserService _userService = UserService();
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _userRole = 'user'; // Default userRole
  String _name = '';

  Future<void> _showUserDialog([VibeHubUser? user]) async {
    if (user != null) {
      _email = user.email;
      _password = user.password;
      _userRole = user.userRole;
      _name = user.name;
    } else {
      _email = '';
      _password = '';
      _userRole = 'user'; // Reset to default
      _name = '';
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user == null ? 'Add User' : 'Edit User'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  initialValue: _email,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter an email' : null,
                  onSaved: (value) => _email = value!,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  initialValue: _password,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter a password' : null,
                  onSaved: (value) => _password = value!,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _userRole,
                  items: const [
                    DropdownMenuItem(
                      value: 'user',
                      child: Text('User'),
                    ),
                    DropdownMenuItem(
                      value: 'admin',
                      child: Text('Admin'),
                    ),
                  ],
                  decoration: const InputDecoration(labelText: 'User Role'),
                  onChanged: (value) {
                    setState(() {
                      _userRole = value!;
                    });
                  },
                  onSaved: (value) => _userRole = value!,
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Please select a role' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  initialValue: _name,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter a name' : null,
                  onSaved: (value) => _name = value!,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                if (user == null) {
                  await _userService.addUser(VibeHubUser(
                    uid: '',
                    email: _email,
                    password: _password,
                    userRole: _userRole,
                    name: _name,
                  ));
                } else {
                  await _userService.updateUser(user.uid, {
                    'email': _email,
                    'password': _password,
                    'userRole': _userRole,
                    'name': _name,
                  });
                }
                Navigator.pop(context);
              }
            },
            child: Text(user == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(String uid) async {
    await _userService.deleteUser(uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
      ),
      body: StreamBuilder<List<VibeHubUser>>(
        stream: _userService.getUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users available'));
          }

          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(user.name),
                  subtitle: Text('${user.userRole} - ${user.email}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showUserDialog(user),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteUser(user.uid),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
