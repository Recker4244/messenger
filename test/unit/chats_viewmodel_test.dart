import 'package:flutter_test/flutter_test.dart';
import 'package:sivi_chat/locator.dart';
import 'package:sivi_chat/services/chat_service.dart';
import 'package:sivi_chat/ui/viewmodels/chats_viewmodel.dart';

void main() {
  late ChatsViewModel viewModel;
  late ChatService chatService;

  setUp(() {
    // Reset locator
    if (locator.isRegistered<ChatService>()) {
      locator.unregister<ChatService>();
    }

    chatService = ChatService();
    locator.registerSingleton<ChatService>(chatService);

    viewModel = ChatsViewModel();
  });

  tearDown(() {
    if (locator.isRegistered<ChatService>()) {
      locator.unregister<ChatService>();
    }
  });

  group('ChatsViewModel', () {
    test('chats getter should return chats from ChatService', () {
      // Arrange
      const userId = 'user-1';
      final message = {
        'id': 'msg-1',
        'text': 'Test message',
        'timestamp': DateTime.now(),
        'userName': 'Test User',
      };
      // Chat is automatically created when message is added
      chatService.addMessageToChat(userId, message);

      // Act
      final chats = viewModel.chats;

      // Assert
      expect(chats.length, 1);
      expect(chats.first['userId'], userId);
      expect(chats.first['userName'], 'Test User');
    });

    test('chatMessages getter should return messages from ChatService', () {
      // Arrange
      const userId = 'user-1';
      final message = {
        'id': 'msg-1',
        'text': 'Test message',
        'timestamp': DateTime.now(),
      };
      chatService.addMessageToChat(userId, message);

      // Act
      final messages = viewModel.chatMessages;

      // Assert
      expect(messages[userId], isNotNull);
      expect(messages[userId]!.length, 1);
    });

    test('getMessagesForUser should return messages from ChatService', () {
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
      chatService.addMessageToChat(userId, message1);
      chatService.addMessageToChat(userId, message2);

      // Act
      final messages = viewModel.getMessagesForUser(userId);

      // Assert
      expect(messages.length, 2);
      expect(messages.first['text'], 'Message 1');
      expect(messages.last['text'], 'Message 2');
    });

    test('addMessageToChat should add message and notify listeners', () {
      // Arrange
      const userId = 'user-1';
      final message = {
        'id': 'msg-1',
        'text': 'New message',
        'timestamp': DateTime.now(),
      };
      var listenerCalled = false;
      viewModel.addListener(() {
        listenerCalled = true;
      });

      // Act
      viewModel.addMessageToChat(userId, message);

      // Assert
      expect(viewModel.getMessagesForUser(userId).length, 1);
      expect(listenerCalled, true);
    });

    test('setMessagesForChat should set messages and notify listeners', () {
      // Arrange
      const userId = 'user-1';
      final messages = [
        {'id': 'msg-1', 'text': 'Message 1', 'timestamp': DateTime.now()},
        {'id': 'msg-2', 'text': 'Message 2', 'timestamp': DateTime.now()},
      ];
      var listenerCalled = false;
      viewModel.addListener(() {
        listenerCalled = true;
      });

      // Act
      viewModel.setMessagesForChat(userId, messages);

      // Assert
      expect(viewModel.getMessagesForUser(userId).length, 2);
      expect(listenerCalled, true);
    });
  });
}
