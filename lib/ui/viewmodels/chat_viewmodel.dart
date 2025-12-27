import 'package:sivi_chat/services/chat_service.dart';
import 'package:sivi_chat/services/uuid_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../locator.dart';
import '../../services/api_service.dart';

class ChatViewModel extends BaseViewModel {
  final String userId;
  final String userName;

  ApiService _apiService = locator<ApiService>();
  ChatService _chatService = locator<ChatService>();
  SnackbarService snackbarService = locator<SnackbarService>();

  bool _isLoading = false;

  ChatViewModel({required this.userId, required this.userName});

  List<Map> get messages => _chatService.getMessagesForUser(userId);

  bool get isLoading => _isLoading;
  final UuidService _uuidService = locator<UuidService>();

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final message = {
      "id": _uuidService.getRandomUuid(),
      "text": text.trim(),
      "timestamp": DateTime.now(),
      "isSender": true,
      "userId": userId,
      "userName": userName,
    };

    _chatService.addMessageToChat(userId, message);
    notifyListeners();

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.getChatResponse(text.trim());
      if (response != null && response.isNotEmpty) {
        final receiverMessage = {
          "id": _uuidService.getRandomUuid(),
          "text": response['comments'][0]['body'],
          "timestamp": DateTime.now(),
          "isSender": false,
          "userId": userId,
          "userName": userName,
        };
        _chatService.addMessageToChat(userId, receiverMessage);
      }
    } catch (e) {
      snackbarService.showSnackbar(
        message: e.toString(),
        duration: Duration(seconds: 2),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addMessage(Map message) {
    _chatService.addMessageToChat(userId, message);
    notifyListeners();
  }

  void setMessages(List<Map> messages) {
    _chatService.setMessagesForChat(userId, messages);
    notifyListeners();
  }

  Future<void> retryMessage(String text) async {
    await sendMessage(text);
  }
}
