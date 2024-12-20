// test/models/user_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/user.dart';

void main() {
  group('User Model Tests', () {
    test('should create user with valid data', () {
      final user = User(
          uid: 'test123',
          name: 'Test User',
          email: 'test@example.com',
          phoneNumber: '+201234567890',
          notificationsEnabled: true,
          password: 'hashedPassword123',
          profileImagePath: '/path/to/image.jpg');

      expect(user.uid, 'test123');
      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
      expect(user.phoneNumber, '+201234567890');
      expect(user.notificationsEnabled, true);
      expect(user.profileImagePath, '/path/to/image.jpg');
    });

    test('should correctly hash password', () {
      final plainPassword = 'testPassword123';
      final hashedPassword = User.hashPassword(plainPassword);

      expect(hashedPassword, isNot(equals(plainPassword)));
      expect(hashedPassword.length, greaterThan(0));
    });

    test('should convert to and from map', () {
      final user = User(
          id: 1,
          uid: 'test123',
          name: 'Test User',
          email: 'test@example.com',
          phoneNumber: '+201234567890',
          notificationsEnabled: true,
          password: 'hashedPassword123',
          profileImagePath: '/path/to/image.jpg');

      final map = user.toMap();
      final reconstructedUser = User.fromMap(map);

      expect(reconstructedUser.id, user.id);
      expect(reconstructedUser.name, user.name);
      expect(reconstructedUser.email, user.email);
      expect(reconstructedUser.notificationsEnabled, user.notificationsEnabled);
    });
  });
}
