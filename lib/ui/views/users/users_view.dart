import 'package:flutter/material.dart';
import 'package:sivi_chat/locator.dart';
import 'package:sivi_chat/ui/viewmodels/chats_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../viewmodels/users_viewmodel.dart';
import '../chat/chat_view.dart';

class UsersView extends StackedView<UsersViewModel> {
  const UsersView({super.key});
  @override
  UsersViewModel viewModelBuilder(BuildContext context) {
    return UsersViewModel();
  }

  @override
  void onViewModelReady(UsersViewModel model) {
    model.init();
  }

  void _showAddUserDialog(BuildContext context, UsersViewModel model) {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final snackbarService = locator<SnackbarService>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add User'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              hintText: 'Enter user name',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Name cannot be empty';
              }
              if (value.trim().length < 2) {
                return 'Name must be at least 2 characters long';
              }
              if (value.trim().length > 50) {
                return 'Name cannot exceed 50 characters';
              }
              // Check for valid characters (letters, spaces, hyphens, apostrophes)
              final nameRegex = RegExp(r"^[a-zA-Z\s\-']+$");
              if (!nameRegex.hasMatch(value.trim())) {
                return 'Name can only contain letters, spaces, hyphens, and apostrophes';
              }
              return null; // Return null if validation passes
            },
            onFieldSubmitted: (value) {
              if (formKey.currentState?.validate() == true) {
                final userName = nameController.text.trim();
                model.addUser(userName);
                snackbarService.showSnackbar(
                  message: 'User $userName added successfully!',
                  duration: const Duration(seconds: 2),
                );
                Navigator.pop(context);
              }
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState?.validate() == true) {
                final userName = nameController.text.trim();
                model.addUser(userName);

                Navigator.pop(context);
              }
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
      body: model.users.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No Users have been Added',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your contacts to chat with them',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              //physics: ClampingScrollPhysics(),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatView(
                          userId: user['id'] ?? '',
                          userName: userName,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
