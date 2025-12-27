import 'package:sivi_chat/locator.dart';
import 'package:sivi_chat/services/uuid_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'chats_viewmodel.dart';

class UsersViewModel extends BaseViewModel {
  void init() {
    //dummy data
    _users = [
      {'id': 'a3f1c9d2-2b44-4e6e-9b6f-8d1c0e5f1a01', 'name': 'User 1'},
      {'id': 'b4d2e8a1-5c77-4c9a-8f3e-1a9d7b2c1a02', 'name': 'User 2'},
      {'id': 'c5e8f4d1-7a33-4b9e-9a2c-3f8d1e0b1a03', 'name': 'User 3'},
      {'id': 'd6a9e2b4-9f11-4d7c-8e1a-5c3b2f9d1a04', 'name': 'User 4'},
      {'id': 'e7b1f3c5-1d88-4a6b-9c4e-7f2a3d8b1a05', 'name': 'User 5'},
      {'id': 'f8c2d4a6-3e99-4f8d-8b5a-9e1c7d2f1a06', 'name': 'User 6'},
      {'id': '19a3d5e7-6f22-4c1a-9d8b-2e4f7c1a1a07', 'name': 'User 7'},
      {'id': '2ab4e6f8-8c44-4b2d-9e1a-3d5f7c2b1a08', 'name': 'User 8'},
      {'id': '3bc5f7a9-0d66-4e3c-8f2b-4a6e1d9c1a09', 'name': 'User 9'},
      {'id': '4cd6a8b1-2e77-4f4d-9a3c-5b7e2f8d1a10', 'name': 'User 10'},
      {'id': '5de7b9c2-4f88-4a5e-8b4d-6c1a3e9f1a11', 'name': 'User 11'},
      {'id': '6ef8c1d3-6a99-4b6f-9c5e-7d2b4a1f1a12', 'name': 'User 12'},
      {'id': '7f19d2e4-8b11-4c7a-8d6f-8e3c5b2a1a13', 'name': 'User 13'},
      {'id': '8a2c3f5e-0c22-4d8b-9e7a-9f4d6c3b1a14', 'name': 'User 14'},
      {'id': '9b3d4a6f-2d33-4e9c-8f8b-0a5e7d4c1a15', 'name': 'User 15'},
    ];
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
}
