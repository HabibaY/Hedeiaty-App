import 'dart:convert'; // Required for Base64 encoding
import 'package:crypto/crypto.dart'; // Required for hashing

class User {
  final int? id;
  final String uid;
  final String name;
  final String email;
  final String phoneNumber;
  final bool notificationsEnabled;
  final String password; // Already hashed when passed to the model
  final String profileImagePath; // Added profile image path field

  User({
    this.id,
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.notificationsEnabled,
    required this.password,
    required this.profileImagePath, // Initialize the new field
  });

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'id': id,

      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'notificationsEnabled': notificationsEnabled ? 1 : 0, // Boolean to int
      'password': password, // Already hashed
      'profileImagePath': profileImagePath, // Include the new field
    };
  }

  // Convert from Map
  static User fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      notificationsEnabled: map['notificationsEnabled'] == 1, // Int to bool
      password: map['password'], // Already hashed
      profileImagePath: map['profileImagePath'], // Map the new field
    );
  }

  // Static method to hash password using Base64
  static String hashPassword(String password) {
    final bytes = password.codeUnits; // Convert to a list of UTF-16 code units
    final hashedBytes =
        sha256.convert(bytes).bytes; // Hash the bytes using SHA-256
    return base64Encode(hashedBytes); // Encode the hashed bytes in Base64
  }
}
