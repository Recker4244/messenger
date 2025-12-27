import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:sivi_chat/locator.dart';
import 'package:sivi_chat/services/api_service.dart';
import 'package:sivi_chat/services/chat_service.dart';
import 'package:sivi_chat/services/uuid_service.dart';
import 'package:sivi_chat/ui/viewmodels/chat_viewmodel.dart';
import 'package:stacked_services/stacked_services.dart';

import 'chat_viewmodel_test.mocks.dart';

@GenerateMocks([ApiService, ChatService, UuidService, SnackbarService])
void main() {
  late ChatViewModel viewModel;
  late MockApiService mockApiService;
  late MockChatService mockChatService;
  late MockUuidService mockUuidService;
  late MockSnackbarService mockSnackbarService;

  setUp(() {
    if (locator.isRegistered<ApiService>()) {
      locator.unregister<ApiService>();
    }
    if (locator.isRegistered<ChatService>()) {
      locator.unregister<ChatService>();
    }
    if (locator.isRegistered<UuidService>()) {
      locator.unregister<UuidService>();
    }
    if (locator.isRegistered<SnackbarService>()) {
      locator.unregister<SnackbarService>();
    }

    mockApiService = MockApiService();
    mockChatService = MockChatService();
    mockUuidService = MockUuidService();
    mockSnackbarService = MockSnackbarService();

    locator.registerSingleton<ApiService>(mockApiService);
    locator.registerSingleton<ChatService>(mockChatService);
    locator.registerSingleton<UuidService>(mockUuidService);
    locator.registerSingleton<SnackbarService>(mockSnackbarService);

    viewModel = ChatViewModel(userId: 'user-1', userName: 'Test User');
  });

  tearDown(() {
    if (locator.isRegistered<ApiService>()) {
      locator.unregister<ApiService>();
    }
    if (locator.isRegistered<ChatService>()) {
      locator.unregister<ChatService>();
    }
    if (locator.isRegistered<UuidService>()) {
      locator.unregister<UuidService>();
    }
    if (locator.isRegistered<SnackbarService>()) {
      locator.unregister<SnackbarService>();
    }
  });

  group('ChatViewModel', () {
    test('should initialize with userId and userName', () {
      expect(viewModel.userId, 'user-1');
      expect(viewModel.userName, 'Test User');
    });

    test('isLoading should be false initially', () {
      expect(viewModel.isLoading, false);
    });

    test('messages should return messages from ChatService', () {
      final expectedMessages = [
        {
          'id': 'msg-1',
          'text': 'Hello',
          'timestamp': DateTime.now(),
          'isSender': true,
        },
      ];
      when(
        mockChatService.getMessagesForUser('user-1'),
      ).thenReturn(expectedMessages);

      final messages = viewModel.messages;

      expect(messages, expectedMessages);
      verify(mockChatService.getMessagesForUser('user-1')).called(1);
    });

    test('sendMessage should add message and call API', () async {
      const messageText = 'Hello, world!';
      const messageId = 'msg-123';
      const receiverMessageId = 'msg-456';
      final apiResponse = {
        'comments': [
          {'body': 'Response message'},
        ],
      };

      var callCount = 0;
      when(mockUuidService.getRandomUuid()).thenAnswer((_) {
        callCount++;
        return callCount == 1 ? messageId : receiverMessageId;
      });
      when(mockChatService.getMessagesForUser('user-1')).thenReturn([]);
      when(
        mockApiService.getChatResponse(messageText),
      ).thenAnswer((_) async => apiResponse);

      await viewModel.sendMessage(messageText);

      verify(mockUuidService.getRandomUuid()).called(2);
      verify(mockChatService.addMessageToChat('user-1', any)).called(2);
      verify(mockApiService.getChatResponse(messageText)).called(1);
      expect(viewModel.isLoading, false);
    });

    test('sendMessage should not send empty message', () async {
      await viewModel.sendMessage('');
      await viewModel.sendMessage('   ');

      verifyNever(mockApiService.getChatResponse(any));
      verifyNever(mockChatService.addMessageToChat(any, any));
    });

    test('sendMessage should trim message text', () async {
      const messageText = '  Hello  ';
      const messageId = 'msg-123';
      final apiResponse = {
        'comments': [
          {'body': 'Response'},
        ],
      };

      when(mockUuidService.getRandomUuid()).thenReturn(messageId);
      when(mockChatService.getMessagesForUser('user-1')).thenReturn([]);
      when(
        mockApiService.getChatResponse('Hello'),
      ).thenAnswer((_) async => apiResponse);

      await viewModel.sendMessage(messageText);

      verify(mockApiService.getChatResponse('Hello')).called(1);
    });

    test('sendMessage should handle API errors gracefully', () async {
      const messageText = 'Test message';
      const messageId = 'msg-123';
      final error = Exception('Network error');

      when(mockUuidService.getRandomUuid()).thenReturn(messageId);
      when(mockChatService.getMessagesForUser('user-1')).thenReturn([]);
      when(mockApiService.getChatResponse(messageText)).thenThrow(error);

      await viewModel.sendMessage(messageText);

      verify(mockChatService.addMessageToChat('user-1', any)).called(1);
      verify(
        mockSnackbarService.showSnackbar(
          message: anyNamed('message'),
          duration: anyNamed('duration'),
        ),
      ).called(1);
      expect(viewModel.isLoading, false);
    });

    test('sendMessage should set isLoading to true during API call', () async {
      const messageText = 'Test message';
      const messageId = 'msg-123';
      final apiResponse = {
        'comments': [
          {'body': 'Response'},
        ],
      };

      when(mockUuidService.getRandomUuid()).thenReturn(messageId);
      when(mockChatService.getMessagesForUser('user-1')).thenReturn([]);
      when(mockApiService.getChatResponse(messageText)).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return apiResponse;
      });

      viewModel.sendMessage(messageText);

      await Future.delayed(const Duration(milliseconds: 50));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(viewModel.isLoading, false);
    });

    test('addMessage should add message to chat', () {
      final message = {
        'id': 'msg-1',
        'text': 'Test message',
        'timestamp': DateTime.now(),
      };
      var listenerCalled = false;
      viewModel.addListener(() {
        listenerCalled = true;
      });

      viewModel.addMessage(message);

      verify(mockChatService.addMessageToChat('user-1', message)).called(1);
      expect(listenerCalled, true);
    });

    test('setMessages should set messages for chat', () {
      final messages = [
        {'id': 'msg-1', 'text': 'Message 1', 'timestamp': DateTime.now()},
      ];
      var listenerCalled = false;
      viewModel.addListener(() {
        listenerCalled = true;
      });

      viewModel.setMessages(messages);

      verify(mockChatService.setMessagesForChat('user-1', messages)).called(1);
      expect(listenerCalled, true);
    });

    test('retryMessage should call sendMessage', () async {
      const messageText = 'Retry message';
      const messageId = 'msg-123';
      final apiResponse = {
        'comments': [
          {'body': 'Response'},
        ],
      };

      when(mockUuidService.getRandomUuid()).thenReturn(messageId);
      when(mockChatService.getMessagesForUser('user-1')).thenReturn([]);
      when(
        mockApiService.getChatResponse(messageText),
      ).thenAnswer((_) async => apiResponse);

      await viewModel.retryMessage(messageText);

      verify(mockApiService.getChatResponse(messageText)).called(1);
    });
  });
}
