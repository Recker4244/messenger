import 'package:sivi_chat/locator.dart';
import 'package:sivi_chat/services/uuid_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'chats_viewmodel.dart';

class UsersViewModel extends BaseViewModel {
  void init() {
    _users = [];
    notifyListeners();
  }

  List<Map<String, String>> _users = [];
  List<Map<String, String>> get users => _users;
  final UuidService _uuidService = locator<UuidService>();

  void addUser(String name) {
    if (name.trim().isEmpty) return;
    SnackbarService snackbarService = locator<SnackbarService>();
    if (users.any((user) {
      return user['name'] == name;
    })) {
      snackbarService.showSnackbar(
        message: "$name has already been added",
        duration: const Duration(seconds: 2),
      );
      return;
    }

    _users.add({'id': _uuidService.getRandomUuid(), 'name': name.trim()});
    snackbarService.showSnackbar(
      message: 'User $name added successfully!',
      duration: const Duration(seconds: 2),
    );
    notifyListeners();
  }

  void startChatWithUser(Map<String, String> user) {
    ChatsViewModel().addChat(user);
  }
}
