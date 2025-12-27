import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:sivi_chat/locator.dart';
import 'package:sivi_chat/services/uuid_service.dart';
import 'package:sivi_chat/ui/viewmodels/users_viewmodel.dart';
import 'package:stacked_services/stacked_services.dart';

import 'users_viewmodel_test.mocks.dart';

@GenerateMocks([UuidService, SnackbarService])
void main() {
  late UsersViewModel viewModel;
  late MockUuidService mockUuidService;
  late MockSnackbarService mockSnackbarService;

  setUp(() {
    // Reset locator
    if (locator.isRegistered<UuidService>()) {
      locator.unregister<UuidService>();
    }
    if (locator.isRegistered<SnackbarService>()) {
      locator.unregister<SnackbarService>();
    }

    mockUuidService = MockUuidService();
    mockSnackbarService = MockSnackbarService();

    locator.registerSingleton<UuidService>(mockUuidService);
    locator.registerSingleton<SnackbarService>(mockSnackbarService);

    viewModel = UsersViewModel();
  });

  tearDown(() {
    if (locator.isRegistered<UuidService>()) {
      locator.unregister<UuidService>();
    }
    if (locator.isRegistered<SnackbarService>()) {
      locator.unregister<SnackbarService>();
    }
  });

  group('UsersViewModel', () {
    test('init should initialize users list with default users', () {
      // Act
      viewModel.init();

      // Assert
      expect(viewModel.users.length, greaterThan(0));
      expect(viewModel.users.first, containsPair('id', isA<String>()));
      expect(viewModel.users.first, containsPair('name', isA<String>()));
    });

    test('addUser should add a new user with valid name', () {
      // Arrange
      const testUuid = 'test-uuid-123';
      const userName = 'John Doe';
      when(mockUuidService.getRandomUuid()).thenReturn(testUuid);
      when(
        mockSnackbarService.showSnackbar(
          message: anyNamed('message'),
          duration: anyNamed('duration'),
        ),
      ).thenReturn(null);

      viewModel.init();
      final initialCount = viewModel.users.length;

      // Act
      viewModel.addUser(userName);

      // Assert
      expect(viewModel.users.length, initialCount + 1);
      expect(viewModel.users.last, {'id': testUuid, 'name': userName});
      verify(mockUuidService.getRandomUuid()).called(1);
      verify(
        mockSnackbarService.showSnackbar(
          message: anyNamed('message'),
          duration: anyNamed('duration'),
        ),
      ).called(1);
    });

    test('addUser should trim whitespace from name', () {
      // Arrange
      const testUuid = 'test-uuid-456';
      const userNameWithSpaces = '  Jane Smith  ';
      const expectedName = 'Jane Smith';
      when(mockUuidService.getRandomUuid()).thenReturn(testUuid);
      when(
        mockSnackbarService.showSnackbar(
          message: anyNamed('message'),
          duration: anyNamed('duration'),
        ),
      ).thenReturn(null);

      viewModel.init();

      // Act
      viewModel.addUser(userNameWithSpaces);

      // Assert
      expect(viewModel.users.last['name'], expectedName);
    });

    test('addUser should not add user if name is empty', () {
      // Arrange
      viewModel.init();
      final initialCount = viewModel.users.length;

      // Act
      viewModel.addUser('');
      viewModel.addUser('   ');

      // Assert
      expect(viewModel.users.length, initialCount);
      verifyNever(mockUuidService.getRandomUuid());
    });

    test('addUser should show error if user already exists', () {
      // Arrange
      const userName = 'Existing User';
      const testUuid = 'test-uuid-789';
      when(mockUuidService.getRandomUuid()).thenReturn(testUuid);
      when(
        mockSnackbarService.showSnackbar(
          message: anyNamed('message'),
          duration: anyNamed('duration'),
        ),
      ).thenReturn(null);

      viewModel.init();
      viewModel.addUser(userName);
      final initialCount = viewModel.users.length;

      // Act
      viewModel.addUser(userName);

      // Assert
      expect(viewModel.users.length, initialCount);
      verify(
        mockSnackbarService.showSnackbar(
          message: anyNamed('message'),
          duration: anyNamed('duration'),
        ),
      ).called(2); // Once for add, once for error
    });

    test('users getter should return the current users list', () {
      // Arrange
      viewModel.init();

      // Act
      final users = viewModel.users;

      // Assert
      expect(users, isA<List<Map<String, String>>>());
      expect(users, isNotEmpty);
    });
  });
}
