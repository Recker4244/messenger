import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../viewmodels/users_viewmodel.dart';

class UsersView extends StackedView<UsersViewModel> {
  const UsersView({super.key});
  @override
  UsersViewModel viewModelBuilder(BuildContext context) => UsersViewModel();

  void _showAddUserDialog(BuildContext context, UsersViewModel model) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add User'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: 'Enter user name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              model.addUser(nameController.text);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget builder(BuildContext context, UsersViewModel model, Widget? child) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddUserDialog(context, model);
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: model.users.length,
        itemBuilder: (context, index) {
          final user = model.users[index];
          final userName = user['name'] ?? '';
          return ListTile(
            leading: CircleAvatar(
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : '?',
              ),
            ),
            title: Text(userName),
            onTap: () {
              model.startChatWithUser(user);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Chat started with $userName')),
              );
            },
          );
        },
      ),
    );
  }
}
