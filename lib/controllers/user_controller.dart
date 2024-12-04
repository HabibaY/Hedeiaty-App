// import '../models/user.dart';
// import '../services/local_storage_service.dart';

// class UserController {
//   final LocalStorageService _localStorageService = LocalStorageService();

//   // Add a new user
//   Future<void> addUser(
//       String name, String email, String phoneNumber, String password, bool notificationsEnabled, String preferences) async {
//     User user = User(
//       name: name,
//       email: email,
//       phoneNumber: phoneNumber,
//       password: password,
//       notificationsEnabled: notificationsEnabled,
//       preferences: preferences,
//     );
//     await _localStorageService.insertUser(user.toMap());
//   }

//   // Retrieve all users
//   Future<List<User>> getUsers() async {
//     List<Map<String, dynamic>> usersMap = await _localStorageService.getUsers();
//     return usersMap.map((map) => User.fromMap(map)).toList();
//   }

//   // Update an existing user
//   Future<void> updateUser(User updatedUser) async {
//     await _localStorageService.updateUser(updatedUser.toMap());
//   }

//   // Delete a user
//   Future<void> deleteUser(int userId) async {
//     await _localStorageService.deleteUser(userId);
//   }
// }
