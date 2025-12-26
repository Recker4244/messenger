import 'package:stacked/stacked.dart';
import 'chats_viewmodel.dart';

class UsersViewModel extends BaseViewModel {
  void init() {
    _users = [];
    notifyListeners();
  }

  List<Map<String, String>> _users = [];
  List<Map<String, String>> get users => _users;

  void addUser(String name) {
    if (name.trim().isEmpty) return;

    _users.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name.trim(),
    });
    notifyListeners();
  }

  void startChatWithUser(Map<String, String> user) {
    ChatsViewModel().addChat(user);
  }
}
