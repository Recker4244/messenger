import 'package:stacked/stacked.dart';
import '../../locator.dart';
import '../../services/chat_service.dart';

class ChatsViewModel extends BaseViewModel {
  ChatService _chatService = locator<ChatService>();

  List<Map<String, dynamic>> get chats => _chatService.chats;
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
