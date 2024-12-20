import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/controllers/user_controller.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:mockito/mockito.dart'; // For mocking
import 'package:flutter_application_1/storage/local_storage_service.dart'; // LocalStorageService

class MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  late MockLocalStorageService mockLocalStorageService;
  late UserController userController;

  setUp(() {
    mockLocalStorageService = MockLocalStorageService();
    userController = UserController();
  });

  group('UserController Tests', () {
    test('Add user to local storage', () async {
      // Arrange
      final userData = {
        'uid': '123',
        'name': 'John Doe',
        'email': 'john.doe@example.com',
        'phoneNumber': '1234567890',
        'notificationsEnabled': true,
        'password': 'hashedpassword',
        'profileImagePath': '/path/to/image',
      };

      when(mockLocalStorageService.insertUser(userData))
          .thenAnswer((_) async => 1);

      // Act
      await userController.addUser(
        '123',
        'John Doe',
        'john.doe@example.com',
        '1234567890',
        true,
        'hashedpassword',
        '/path/to/image',
      );

      // Assert
      verify(mockLocalStorageService.insertUser(userData)).called(1);
    });

    test('Fetch all users from local storage', () async {
      // Arrange
      final mockUsers = [
        {
          'uid': '123',
          'name': 'John Doe',
          'email': 'john.doe@example.com',
          'phoneNumber': '1234567890',
          'notificationsEnabled': true,
          'password': 'hashedpassword',
          'profileImagePath': '/path/to/image',
        }
      ];

      when(mockLocalStorageService.getUsers())
          .thenAnswer((_) async => mockUsers);

      // Act
      final users = await userController.getUsers();

      // Assert
      expect(users.length, 1);
      expect(users.first.name, 'John Doe');
    });
  });
}
