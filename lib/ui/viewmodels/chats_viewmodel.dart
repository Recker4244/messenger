import 'package:stacked/stacked.dart';
import '../../locator.dart';
import '../../services/chat_service.dart';

class ChatsViewModel extends BaseViewModel {
  ChatService _chatService = locator<ChatService>();

  List<Map<String, dynamic>> get chats {
    final unsortedChats = _chatService.chats;
    final sortedChats = List<Map<String, dynamic>>.from(unsortedChats);
    sortedChats.sort((a, b) {
      final timeA = a['lastMessageTime'] as DateTime?;
      final timeB = b['lastMessageTime'] as DateTime?;

      if (timeA == null && timeB == null) return 0;
      if (timeA == null) return 1;
      if (timeB == null) return -1;

      return timeB.compareTo(timeA);
    });
    return sortedChats;
  }

  Map<String, List<Map>> get chatMessages => _chatService.chatMessages;

  List<Map> getMessagesForUser(String userId) {
    return _chatService.getMessagesForUser(userId);
  }

  void addMessageToChat(String userId, Map message) {
    _chatService.addMessageToChat(userId, message);
    notifyListeners();
  }

  void setMessagesForChat(String userId, List<Map> messages) {
    _chatService.setMessagesForChat(userId, messages);
    notifyListeners();
  }
}
