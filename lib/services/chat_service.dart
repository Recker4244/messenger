class ChatService {
  List<Map<String, dynamic>> _chats = [];
  Map<String, List<Map>> _chatMessages = {};

  List<Map<String, dynamic>> get chats => _chats;
  Map<String, List<Map>> get chatMessages => _chatMessages;

  List<Map> getMessagesForUser(String userId) {
    if (!_chatMessages.containsKey(userId)) {
      _chatMessages[userId] = [];
    }
    return _chatMessages[userId]!;
  }

  void addMessageToChat(String userId, Map message) {
    if (!_chatMessages.containsKey(userId)) {
      _chatMessages[userId] = [];
    }
    _chatMessages[userId]!.add(message);

    final chatIndex = _chats.indexWhere((chat) => chat['userId'] == userId);
    if (chatIndex != -1) {
      _chats[chatIndex]['lastMessage'] = message['text'];
      _chats[chatIndex]['lastMessageTime'] = message['timestamp'];
    } else
      _chats.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'userId': userId,
        'userName': message['userName'],
        'lastMessage': message['text'],
        'lastMessageTime': message['timestamp'],
      });
  }

  void setMessagesForChat(String userId, List<Map> messages) {
    _chatMessages[userId] = messages;

    if (messages.isNotEmpty) {
      final lastMessage = messages.last;
      final chatIndex = _chats.indexWhere((chat) => chat['userId'] == userId);
      if (chatIndex != -1) {
        _chats[chatIndex]['lastMessage'] = lastMessage['text'];
        _chats[chatIndex]['lastMessageTime'] = lastMessage['timestamp'];
      }
    }
  }

  Map<String, dynamic>? getChatForUser(String userId) {
    return _chats.firstWhere(
      (chat) => chat['userId'] == userId,
      orElse: () => {},
    );
  }
}
