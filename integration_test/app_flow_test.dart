import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sivi_chat/main.dart' as app;
import 'package:sivi_chat/locator.dart';
import 'package:sivi_chat/services/chat_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Flow Integration Tests', () {
    setUp(() {
      if (!locator.isRegistered<ChatService>()) {
        setupLocator();
      }
    });

    testWidgets('Complete flow: Add user, create chat, send message', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const app.MyApp());
      await tester.pumpAndSettle();

      final usersTab = find.text('Users');
      if (usersTab.evaluate().isNotEmpty) {
        await tester.tap(usersTab);
        await tester.pumpAndSettle();
      }

      final addButton = find.byType(FloatingActionButton);
      expect(addButton, findsOneWidget);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      expect(find.text('Add User'), findsOneWidget);
      expect(find.text('Enter user name'), findsOneWidget);

      const userName = 'Test User Integration';
      final textField = find.byType(TextFormField);
      expect(textField, findsOneWidget);
      await tester.enterText(textField, userName);
      await tester.pumpAndSettle();

      final addDialogButton = find.text('Add');
      expect(addDialogButton, findsOneWidget);
      await tester.tap(addDialogButton);
      await tester.pumpAndSettle();

      expect(find.text(userName), findsOneWidget);

      final userTile = find.text(userName);
      expect(userTile, findsOneWidget);
      await tester.tap(userTile);
      await tester.pumpAndSettle();

      expect(find.text(userName), findsWidgets);

      const messageText = 'Hello, this is a test message!';
      final messageTextField = find.byType(TextField);
      expect(messageTextField, findsOneWidget);

      await tester.enterText(messageTextField, messageText);
      await tester.pumpAndSettle();

      final sendButton = find.byIcon(Icons.send);
      expect(sendButton, findsOneWidget);
      await tester.tap(sendButton);
      await tester.pumpAndSettle();

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.text(messageText), findsOneWidget);

      final backButton = find.byType(BackButton);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();
      } else {
        final appBarBack = find.byIcon(Icons.arrow_back);
        if (appBarBack.evaluate().isNotEmpty) {
          await tester.tap(appBarBack);
          await tester.pumpAndSettle();
        }
      }

      final chatsTab = find.text('Chats');
      if (chatsTab.evaluate().isNotEmpty) {
        await tester.tap(chatsTab);
        await tester.pumpAndSettle();

        expect(find.text(userName), findsOneWidget);
        expect(
          find.textContaining(messageText.substring(0, 10)),
          findsOneWidget,
        );
      }
    });

    testWidgets('Add user validation test', (WidgetTester tester) async {
      await tester.pumpWidget(const app.MyApp());
      await tester.pumpAndSettle();

      final usersTab = find.text('Users');
      if (usersTab.evaluate().isNotEmpty) {
        await tester.tap(usersTab);
        await tester.pumpAndSettle();
      }

      final addButton = find.byType(FloatingActionButton);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      final addDialogButton = find.text('Add');
      await tester.tap(addDialogButton);
      await tester.pumpAndSettle();

      expect(find.text('Name cannot be empty'), findsOneWidget);

      final textField = find.byType(TextFormField);
      await tester.enterText(textField, 'A');
      await tester.pumpAndSettle();
      await tester.tap(addDialogButton);
      await tester.pumpAndSettle();

      expect(
        find.text('Name must be at least 2 characters long'),
        findsOneWidget,
      );

      final cancelButton = find.text('Cancel');
      await tester.tap(cancelButton);
      await tester.pumpAndSettle();
    });

    testWidgets('Send multiple messages test', (WidgetTester tester) async {
      await tester.pumpWidget(const app.MyApp());
      await tester.pumpAndSettle();

      final usersTab = find.text('Users');
      if (usersTab.evaluate().isNotEmpty) {
        await tester.tap(usersTab);
        await tester.pumpAndSettle();
      }

      final userListTiles = find.byType(ListTile);
      if (userListTiles.evaluate().isEmpty) {
        final addButton = find.byType(FloatingActionButton);
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        const userName = 'Multi Message User';
        final textField = find.byType(TextFormField);
        await tester.enterText(textField, userName);
        await tester.pumpAndSettle();

        final addDialogButton = find.text('Add');
        await tester.tap(addDialogButton);
        await tester.pumpAndSettle();
      }

      final firstUserTile = find.byType(ListTile).first;
      await tester.tap(firstUserTile);
      await tester.pumpAndSettle();

      final messageTextField = find.byType(TextField);
      final sendButton = find.byIcon(Icons.send);

      const messages = ['First message', 'Second message', 'Third message'];

      for (final message in messages) {
        await tester.enterText(messageTextField, message);
        await tester.pumpAndSettle();
        await tester.tap(sendButton);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();
      }

      for (final message in messages) {
        expect(find.text(message), findsOneWidget);
      }
    });

    testWidgets('Chat list updates after sending message', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const app.MyApp());
      await tester.pumpAndSettle();

      final usersTab = find.text('Users');
      if (usersTab.evaluate().isNotEmpty) {
        await tester.tap(usersTab);
        await tester.pumpAndSettle();
      }

      final addButton = find.byType(FloatingActionButton);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      const userName = 'Chat List Test User';
      final textField = find.byType(TextFormField);
      await tester.enterText(textField, userName);
      await tester.pumpAndSettle();

      final addDialogButton = find.text('Add');
      await tester.tap(addDialogButton);
      await tester.pumpAndSettle();

      final userTile = find.text(userName);
      await tester.tap(userTile);
      await tester.pumpAndSettle();

      const messageText = 'Test message for chat list';
      final messageTextField = find.byType(TextField);
      await tester.enterText(messageTextField, messageText);
      await tester.pumpAndSettle();

      final sendButton = find.byIcon(Icons.send);
      await tester.tap(sendButton);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      final backButton = find.byType(BackButton);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();
      }

      final chatsTab = find.text('Chats');
      await tester.tap(chatsTab);
      await tester.pumpAndSettle();

      expect(find.text(userName), findsOneWidget);
      expect(find.textContaining(messageText.substring(0, 15)), findsOneWidget);
    });
  });
}
