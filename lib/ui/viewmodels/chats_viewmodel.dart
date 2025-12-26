import 'package:stacked/stacked.dart';

class ChatsViewModel extends BaseViewModel {
  void init() {
    _chats = [];
  }

  List<Map<String, dynamic>> _chats = [];
  List<Map<String, dynamic>> get chats => _chats;

  void addChat(Map<String, String> user) {
    final existingChatIndex = _chats.indexWhere(
      (chat) => chat['userId'] == user['id'],
    );

    if (existingChatIndex == -1) {
      _chats.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'userId': user['id'],
        'userName': user['name'],
        'lastMessage': 'Chat started',
        'lastMessageTime': DateTime.now(),
      });
      notifyListeners();
    }
  }
}
