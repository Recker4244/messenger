import 'package:flutter_test/flutter_test.dart';
import 'package:sivi_chat/services/chat_service.dart';

void main() {
  late ChatService chatService;

  setUp(() {
    chatService = ChatService();
  });

  group('ChatService', () {
    test('getMessagesForUser should return empty list for new user', () {
      // Arrange
      const userId = 'user-1';

      // Act
      final messages = chatService.getMessagesForUser(userId);

      // Assert
      expect(messages, isEmpty);
      expect(chatService.chatMessages[userId], isNotNull);
    });

    test('getMessagesForUser should return messages for existing user', () {
      // Arrange
      const userId = 'user-1';
      final message1 = {
        'id': 'msg-1',
        'text': 'Hello',
        'timestamp': DateTime.now(),
        'isSender': true,
      };
      final message2 = {
        'id': 'msg-2',
        'text': 'Hi there',
        'timestamp': DateTime.now(),
        'isSender': false,
      };

      // Act
      chatService.addMessageToChat(userId, message1);
      chatService.addMessageToChat(userId, message2);
      final messages = chatService.getMessagesForUser(userId);

      // Assert
      expect(messages.length, 2);
      expect(messages.first['text'], 'Hello');
      expect(messages.last['text'], 'Hi there');
    });

    test('addMessageToChat should create chat if it does not exist', () {
      // Arrange
      const userId = 'user-2';
      final message = {
        'id': 'msg-1',
        'text': 'New chat message',
        'timestamp': DateTime.now(),
        'isSender': true,
        'userName': 'New User',
      };

      // Act
      chatService.addMessageToChat(userId, message);

      // Assert
      expect(chatService.chats.length, 1);
      expect(chatService.chats.first['userId'], userId);
      expect(chatService.chats.first['userName'], 'New User');
      expect(chatService.chats.first['lastMessage'], 'New chat message');
      expect(chatService.getMessagesForUser(userId).length, 1);
    });

    test('setMessagesForChat should replace all messages for a user', () {
      // Arrange
      const userId = 'user-1';
      final message1 = {
        'id': 'msg-1',
        'text': 'Message 1',
        'timestamp': DateTime.now(),
      };
      final message2 = {
        'id': 'msg-2',
        'text': 'Message 2',
        'timestamp': DateTime.now(),
      };
      final newMessages = [
        {'id': 'msg-3', 'text': 'New Message 1', 'timestamp': DateTime.now()},
        {'id': 'msg-4', 'text': 'New Message 2', 'timestamp': DateTime.now()},
      ];

      // Act
      chatService.addMessageToChat(userId, message1);
      chatService.addMessageToChat(userId, message2);
      chatService.setMessagesForChat(userId, newMessages);

      // Assert
      final messages = chatService.getMessagesForUser(userId);
      expect(messages.length, 2);
      expect(messages.first['text'], 'New Message 1');
      expect(messages.last['text'], 'New Message 2');
    });

    test('getChatForUser should return empty map for non-existent user', () {
      // Act
      final chat = chatService.getChatForUser('non-existent');

      // Assert
      expect(chat, isEmpty);
    });
  });
}
