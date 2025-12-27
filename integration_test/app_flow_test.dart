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
      // Ensure locator is set up
      if (!locator.isRegistered<ChatService>()) {
        setupLocator();
      }
    });

    testWidgets('Complete flow: Add user, create chat, send message', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(const app.MyApp());
      await tester.pumpAndSettle();

      // Step 1: Navigate to Users tab (if not already there)
      // The app starts with HomeView which has UsersView and ChatsView
      // Find the Users tab button
      final usersTab = find.text('Users');
      if (usersTab.evaluate().isNotEmpty) {
        await tester.tap(usersTab);
        await tester.pumpAndSettle();
      }

      // Step 2: Add a new user
      // Find and tap the floating action button
      final addButton = find.byType(FloatingActionButton);
      expect(addButton, findsOneWidget);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Verify dialog is shown
      expect(find.text('Add User'), findsOneWidget);
      expect(find.text('Enter user name'), findsOneWidget);

      // Enter user name
      const userName = 'Test User Integration';
      final textField = find.byType(TextFormField);
      expect(textField, findsOneWidget);
      await tester.enterText(textField, userName);
      await tester.pumpAndSettle();

      // Tap Add button
      final addDialogButton = find.text('Add');
      expect(addDialogButton, findsOneWidget);
      await tester.tap(addDialogButton);
      await tester.pumpAndSettle();

      // Verify user was added (check if it appears in the list)
      expect(find.text(userName), findsOneWidget);

      // Step 3: Create a chat by tapping on the user
      final userTile = find.text(userName);
      expect(userTile, findsOneWidget);
      await tester.tap(userTile);
      await tester.pumpAndSettle();

      // Verify we navigated to ChatView
      // Check for the user name in the AppBar
      expect(find.text(userName), findsWidgets); // Should appear in AppBar

      // Step 4: Send a message
      const messageText = 'Hello, this is a test message!';
      final messageTextField = find.byType(TextField);
      expect(messageTextField, findsOneWidget);

      // Enter message
      await tester.enterText(messageTextField, messageText);
      await tester.pumpAndSettle();

      // Find and tap send button
      final sendButton = find.byIcon(Icons.send);
      expect(sendButton, findsOneWidget);
      await tester.tap(sendButton);
      await tester.pumpAndSettle();

      // Wait for API call to complete (with timeout)
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Verify message appears in the chat
      // The message should appear in the ListView
      expect(find.text(messageText), findsOneWidget);

      // Step 5: Navigate back to chats
      final backButton = find.byType(BackButton);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();
      } else {
        // Try AppBar back button
        final appBarBack = find.byIcon(Icons.arrow_back);
        if (appBarBack.evaluate().isNotEmpty) {
          await tester.tap(appBarBack);
          await tester.pumpAndSettle();
        }
      }

      // Step 6: Verify chat appears in ChatsView
      // Switch to Chats tab
      final chatsTab = find.text('Chats');
      if (chatsTab.evaluate().isNotEmpty) {
        await tester.tap(chatsTab);
        await tester.pumpAndSettle();

        // Verify the chat appears with the user name
        expect(find.text(userName), findsOneWidget);
        // Verify last message is shown (might be truncated)
        expect(
          find.textContaining(messageText.substring(0, 10)),
          findsOneWidget,
        );
      }
    });

    testWidgets('Add user validation test', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(const app.MyApp());
      await tester.pumpAndSettle();

      // Navigate to Users tab
      final usersTab = find.text('Users');
      if (usersTab.evaluate().isNotEmpty) {
        await tester.tap(usersTab);
        await tester.pumpAndSettle();
      }

      // Open add user dialog
      final addButton = find.byType(FloatingActionButton);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Try to add empty name
      final addDialogButton = find.text('Add');
      await tester.tap(addDialogButton);
      await tester.pumpAndSettle();

      // Verify validation error is shown
      expect(find.text('Name cannot be empty'), findsOneWidget);

      // Try to add name that's too short
      final textField = find.byType(TextFormField);
      await tester.enterText(textField, 'A');
      await tester.pumpAndSettle();
      await tester.tap(addDialogButton);
      await tester.pumpAndSettle();

      // Verify validation error
      expect(
        find.text('Name must be at least 2 characters long'),
        findsOneWidget,
      );

      // Cancel dialog
      final cancelButton = find.text('Cancel');
      await tester.tap(cancelButton);
      await tester.pumpAndSettle();
    });

    testWidgets('Send multiple messages test', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(const app.MyApp());
      await tester.pumpAndSettle();

      // Navigate to Users tab
      final usersTab = find.text('Users');
      if (usersTab.evaluate().isNotEmpty) {
        await tester.tap(usersTab);
        await tester.pumpAndSettle();
      }

      // Add a user if list is empty, or use existing user
      final userListTiles = find.byType(ListTile);
      if (userListTiles.evaluate().isEmpty) {
        // Add a user
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

      // Tap on first user
      final firstUserTile = find.byType(ListTile).first;
      await tester.tap(firstUserTile);
      await tester.pumpAndSettle();

      // Send multiple messages
      final messageTextField = find.byType(TextField);
      final sendButton = find.byIcon(Icons.send);

      const messages = ['First message', 'Second message', 'Third message'];

      for (final message in messages) {
        await tester.enterText(messageTextField, message);
        await tester.pumpAndSettle();
        await tester.tap(sendButton);
        await tester.pumpAndSettle();
        // Wait a bit for API response
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();
      }

      // Verify all messages appear
      for (final message in messages) {
        expect(find.text(message), findsOneWidget);
      }
    });

    testWidgets('Chat list updates after sending message', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(const app.MyApp());
      await tester.pumpAndSettle();

      // Navigate to Users tab
      final usersTab = find.text('Users');
      if (usersTab.evaluate().isNotEmpty) {
        await tester.tap(usersTab);
        await tester.pumpAndSettle();
      }

      // Add a user
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

      // Open chat with user
      final userTile = find.text(userName);
      await tester.tap(userTile);
      await tester.pumpAndSettle();

      // Send a message
      const messageText = 'Test message for chat list';
      final messageTextField = find.byType(TextField);
      await tester.enterText(messageTextField, messageText);
      await tester.pumpAndSettle();

      final sendButton = find.byIcon(Icons.send);
      await tester.tap(sendButton);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Navigate back
      final backButton = find.byType(BackButton);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();
      }

      // Switch to Chats tab
      final chatsTab = find.text('Chats');
      await tester.tap(chatsTab);
      await tester.pumpAndSettle();

      // Verify chat appears with correct last message
      expect(find.text(userName), findsOneWidget);
      expect(find.textContaining(messageText.substring(0, 15)), findsOneWidget);
    });
  });
}
