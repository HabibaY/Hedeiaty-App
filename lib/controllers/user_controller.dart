import '../models/user.dart';
import '../storage/local_storage_service.dart';

class UserController {
  final LocalStorageService _localStorageService = LocalStorageService();

  Future<void> addUser(String uid, String name, String email,
      String phoneNumber, bool notificationsEnabled, String password) async {
    String hashedPassword = User.hashPassword(password); // Hash the password
    User user = User(
      uid: uid,
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      notificationsEnabled: notificationsEnabled,
      password: hashedPassword, // Store the hashed password
    );
    await _localStorageService.insertUser(user.toMap());
  }

  Future<List<User>> getUsers() async {
    List<Map<String, dynamic>> usersMap = await _localStorageService.getUsers();
    return usersMap.map((map) => User.fromMap(map)).toList();
  }

  Future<void> updateUser(User updatedUser) async {
    await _localStorageService.updateUser(updatedUser.toMap());
  }

  Future<void> deleteUser(int userId) async {
    await _localStorageService.deleteUser(userId);
  }

  // Method to verify password
  Future<bool> verifyPassword(String email, String plainPassword) async {
    List<User> users = await getUsers();
    for (var user in users) {
      if (user.email == email) {
        String hashedInput = User.hashPassword(plainPassword);
        return hashedInput == user.password; // Compare hashed passwords
      }
    }
    return false; // User not found or password mismatch
  }
}
