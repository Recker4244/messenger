import 'package:flutter_test/flutter_test.dart';
import 'package:sivi_chat/locator.dart';
import 'package:sivi_chat/services/chat_service.dart';
import 'package:sivi_chat/ui/viewmodels/chats_viewmodel.dart';

void main() {
  late ChatsViewModel viewModel;
  late ChatService chatService;

  setUp(() {
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
      const userId = 'user-1';
      final message = {
        'id': 'msg-1',
        'text': 'Test message',
        'timestamp': DateTime.now(),
        'userName': 'Test User',
      };
      chatService.addMessageToChat(userId, message);

      final chats = viewModel.chats;

      expect(chats.length, 1);
      expect(chats.first['userId'], userId);
      expect(chats.first['userName'], 'Test User');
    });

    test(
      'chats getter should return chats sorted by lastMessageTime (most recent first)',
      () {
        final now = DateTime.now();
        final earlierTime = now.subtract(const Duration(hours: 1));
        final laterTime = now.add(const Duration(hours: 1));

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

        final chats = viewModel.chats;

        expect(chats.length, 3);
        expect(chats[0]['userId'], 'user-2');
        expect(chats[0]['lastMessageTime'], laterTime);
        expect(chats[1]['userId'], 'user-3');
        expect(chats[1]['lastMessageTime'], now);
        expect(chats[2]['userId'], 'user-1');
        expect(chats[2]['lastMessageTime'], earlierTime);
      },
    );

    test('chats with null lastMessageTime should be sorted to the end', () {
      final now = DateTime.now();
      final earlierTime = now.subtract(const Duration(hours: 1));

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

      final chats = chatService.chats;
      chats.add({
        'id': 'chat-3',
        'userId': 'user-3',
        'userName': 'User 3',
        'lastMessage': 'No time',
        'lastMessageTime': null,
      });

      final sortedChats = viewModel.chats;

      expect(sortedChats.length, 3);
      expect(sortedChats[0]['userId'], 'user-2');
      expect(sortedChats[1]['userId'], 'user-1');
      expect(sortedChats[2]['userId'], 'user-3');
      expect(sortedChats[2]['lastMessageTime'], isNull);
    });

    test('chats should re-sort when new message is added', () {
      final now = DateTime.now();
      final earlierTime = now.subtract(const Duration(hours: 1));

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

      var chats = viewModel.chats;
      expect(chats[0]['userId'], 'user-2');
      expect(chats[1]['userId'], 'user-1');

      final laterTime = now.add(const Duration(hours: 2));
      viewModel.addMessageToChat('user-1', {
        'id': 'msg-3',
        'text': 'New message',
        'timestamp': laterTime,
        'userName': 'User 1',
      });

      chats = viewModel.chats;
      expect(chats[0]['userId'], 'user-1');
      expect(chats[0]['lastMessageTime'], laterTime);
      expect(chats[1]['userId'], 'user-2');
    });

    test('chatMessages getter should return messages from ChatService', () {
      const userId = 'user-1';
      final message = {
        'id': 'msg-1',
        'text': 'Test message',
        'timestamp': DateTime.now(),
      };
      chatService.addMessageToChat(userId, message);

      final messages = viewModel.chatMessages;

      expect(messages[userId], isNotNull);
      expect(messages[userId]!.length, 1);
    });

    test('getMessagesForUser should return messages from ChatService', () {
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

      final messages = viewModel.getMessagesForUser(userId);

      expect(messages.length, 2);
      expect(messages.first['text'], 'Message 1');
      expect(messages.last['text'], 'Message 2');
    });

    test('addMessageToChat should add message and notify listeners', () {
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

      viewModel.addMessageToChat(userId, message);

      expect(viewModel.getMessagesForUser(userId).length, 1);
      expect(listenerCalled, true);
    });

    test('setMessagesForChat should set messages and notify listeners', () {
      const userId = 'user-1';
      final messages = [
        {'id': 'msg-1', 'text': 'Message 1', 'timestamp': DateTime.now()},
        {'id': 'msg-2', 'text': 'Message 2', 'timestamp': DateTime.now()},
      ];
      var listenerCalled = false;
      viewModel.addListener(() {
        listenerCalled = true;
      });

      viewModel.setMessagesForChat(userId, messages);

      expect(viewModel.getMessagesForUser(userId).length, 2);
      expect(listenerCalled, true);
    });
  });
}
