import 'dart:convert'; // Required for UTF8 encoding
import 'package:crypto/crypto.dart'; // Required for hashing

class User {
  final int? id;
  final String name;
  final String email;
  final String phoneNumber;
  final bool notificationsEnabled;
  final String password; // Already hashed when passed to the model

  User({
    this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.notificationsEnabled,
    required this.password,
  });

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'notificationsEnabled': notificationsEnabled ? 1 : 0, // Boolean to int
      'password': password, // Already hashed
    };
  }

  // Convert from Map
  static User fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      notificationsEnabled: map['notificationsEnabled'] == 1, // Int to bool
      password: map['password'], // Already hashed
    );
  }

  // Static method to hash password
  static String hashPassword(String password) {
    final bytes = utf8.encode(password); // Convert to bytes
    return sha256.convert(bytes).toString(); // Hash and convert to string
  }
}
