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

    test(
      'chats getter should return chats sorted by lastMessageTime (most recent first)',
      () {
        // Arrange
        final now = DateTime.now();
        final earlierTime = now.subtract(const Duration(hours: 1));
        final laterTime = now.add(const Duration(hours: 1));

        // Add messages in a specific order
        chatService.addMessageToChat('user-1', {
          'id': 'msg-1',
          'text': 'First message',
          'timestamp': earlierTime,
          'userName': 'User 1',
        });

        chatService.addMessageToChat('user-2', {
          'id': 'msg-2',
          'text': 'Second message',
          'timestamp': laterTime,
          'userName': 'User 2',
        });

        chatService.addMessageToChat('user-3', {
          'id': 'msg-3',
          'text': 'Third message',
          'timestamp': now,
          'userName': 'User 3',
        });

        // Act
        final chats = viewModel.chats;

        // Assert
        expect(chats.length, 3);
        // Most recent should be first
        expect(chats[0]['userId'], 'user-2');
        expect(chats[0]['lastMessageTime'], laterTime);
        // Second most recent
        expect(chats[1]['userId'], 'user-3');
        expect(chats[1]['lastMessageTime'], now);
        // Oldest should be last
        expect(chats[2]['userId'], 'user-1');
        expect(chats[2]['lastMessageTime'], earlierTime);
      },
    );

    test('chats with null lastMessageTime should be sorted to the end', () {
      // Arrange
      final now = DateTime.now();
      final earlierTime = now.subtract(const Duration(hours: 1));

      // Add messages
      chatService.addMessageToChat('user-1', {
        'id': 'msg-1',
        'text': 'First message',
        'timestamp': earlierTime,
        'userName': 'User 1',
      });

      chatService.addMessageToChat('user-2', {
        'id': 'msg-2',
        'text': 'Second message',
        'timestamp': now,
        'userName': 'User 2',
      });

      // Manually add a chat with null time (simulating edge case)
      final chats = chatService.chats;
      chats.add({
        'id': 'chat-3',
        'userId': 'user-3',
        'userName': 'User 3',
        'lastMessage': 'No time',
        'lastMessageTime': null,
      });

      // Act
      final sortedChats = viewModel.chats;

      // Assert
      expect(sortedChats.length, 3);
      // Most recent should be first
      expect(sortedChats[0]['userId'], 'user-2');
      // Second should be the one with earlier time
      expect(sortedChats[1]['userId'], 'user-1');
      // Null time should be last
      expect(sortedChats[2]['userId'], 'user-3');
      expect(sortedChats[2]['lastMessageTime'], isNull);
    });

    test('chats should re-sort when new message is added', () {
      // Arrange
      final now = DateTime.now();
      final earlierTime = now.subtract(const Duration(hours: 1));

      // Add initial messages
      chatService.addMessageToChat('user-1', {
        'id': 'msg-1',
        'text': 'First message',
        'timestamp': earlierTime,
        'userName': 'User 1',
      });

      chatService.addMessageToChat('user-2', {
        'id': 'msg-2',
        'text': 'Second message',
        'timestamp': now,
        'userName': 'User 2',
      });

      // Verify initial order
      var chats = viewModel.chats;
      expect(chats[0]['userId'], 'user-2');
      expect(chats[1]['userId'], 'user-1');

      // Act - Add a new message to user-1 with a later time
      final laterTime = now.add(const Duration(hours: 2));
      viewModel.addMessageToChat('user-1', {
        'id': 'msg-3',
        'text': 'New message',
        'timestamp': laterTime,
        'userName': 'User 1',
      });

      // Assert - user-1 should now be first
      chats = viewModel.chats;
      expect(chats[0]['userId'], 'user-1');
      expect(chats[0]['lastMessageTime'], laterTime);
      expect(chats[1]['userId'], 'user-2');
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
