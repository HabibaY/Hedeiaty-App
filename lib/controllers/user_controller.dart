import '../models/user.dart'; // Importing the User model
import '../storage/local_storage_service.dart'; // Importing local storage service
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore operations

class UserController {
  final LocalStorageService _localStorageService = LocalStorageService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Add a new user with all necessary fields, including the profile image path.
  Future<void> addUser(
    String uid,
    String name,
    String email,
    String phoneNumber,
    bool notificationsEnabled,
    String password,
    String profileImagePath, // New parameter for the profile image path
  ) async {
    // Hash the password for secure storage
    String hashedPassword = User.hashPassword(password);

    // Create a User object with all fields
    User user = User(
      uid: uid,
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      notificationsEnabled: notificationsEnabled,
      password: hashedPassword,
      profileImagePath: profileImagePath, // Save the image path
    );

    // Insert the user into local storage
    await _localStorageService.insertUser(user.toMap());
  }

  /// Add a user directly to Firestore
  /// Add a user directly to Firestore
  Future<void> addUserToFirestore({
    required String uid,
    required String name,
    required String email,
    required String phoneNumber,
    required bool notificationsEnabled,
    required String password,
    required String profileImagePath,
  }) async {
    try {
      // Add user document
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'notificationsEnabled': notificationsEnabled,
        'password': password,
        'profileImagePath': profileImagePath,
      });

      // Create placeholder data in Firestore
      final userDoc = _firestore.collection('users').doc(uid);

      // Add a placeholder event
      final eventRef = userDoc.collection('events').doc();
      await eventRef.set({
        'name': 'Placeholder Event',
        'date': DateTime.now().toIso8601String(),
        'location': 'Placeholder Location',
        'description': 'Placeholder Description',
        'category': 'Placeholder Category',
      });

      // Add a placeholder gift under the event
      await eventRef.collection('gifts').doc().set({
        'name': 'Placeholder Gift',
        'description': 'Placeholder Description',
        'category': 'Placeholder Category',
        'price': 0.0,
        'status': 0,
      });

      // Ensure the friends subcollection exists but is empty
      final friendsCollection = userDoc.collection('friends');
      await friendsCollection.doc(); // Create an empty subcollection
    } catch (e) {
      // Handle Firestore exceptions
      print('Error adding user to Firestore: $e');
      rethrow; // Re-throw the error for higher-level handling
    }
  }

  /// Retrieve all users from local storage.
  Future<List<User>> getUsers() async {
    // Fetch user records as maps
    List<Map<String, dynamic>> usersMap = await _localStorageService.getUsers();

    // Convert maps into User objects
    return usersMap.map((map) => User.fromMap(map)).toList();
  }

  /// Update user details in local storage.
  Future<void> updateUser(User updatedUser) async {
    await _localStorageService.updateUser(updatedUser.toMap());
  }

  /// Delete a user by their ID from local storage.
  Future<void> deleteUser(int userId) async {
    await _localStorageService.deleteUser(userId);
  }

  /// Verify if the provided password matches the stored password for a given email.
  Future<bool> verifyPassword(String email, String plainPassword) async {
    // Retrieve all users
    List<User> users = await getUsers();

    for (var user in users) {
      if (user.email == email) {
        // Hash the input password and compare
        String hashedInput = User.hashPassword(plainPassword);
        return hashedInput == user.password;
      }
    }

    // Return false if no match is found
    return false;
  }

  /// Hash a password using the User model's static method.
  String hashPassword(String plainPassword) {
    return User.hashPassword(plainPassword);
  }

  // Reset the local database
  Future<void> resetDatabase() async {
    await _localStorageService.deleteDatabaseFile();
  }

  // Reset the database and reinitialize it
  Future<void> resetDatabaseAndReinitialize() async {
    await resetDatabase(); // Call the reset function
    await _localStorageService.database; // Reinitialize the database
  }

  // Update the profile image path in local storage
// Update the profile image path in local storage
  Future<void> updateUserProfileImage(String uid, String newImagePath) async {
    // Fetch the current user
    List<User> users = await getUsers();
    User? userToUpdate;

    for (var user in users) {
      if (user.uid == uid) {
        userToUpdate = user;
        break;
      }
    }

    if (userToUpdate != null) {
      // Create a new user object with the updated profileImagePath
      User updatedUser = User(
        uid: userToUpdate.uid,
        name: userToUpdate.name,
        email: userToUpdate.email,
        phoneNumber: userToUpdate.phoneNumber,
        notificationsEnabled: userToUpdate.notificationsEnabled,
        password: userToUpdate.password,
        profileImagePath: newImagePath, // Update profile image path
      );

      // Save the updated user back to local storage
      await updateUser(updatedUser);
    }
  }

  // Add this function to your UserController
  /// Update user information in Firestore and local storage.
  /// Updates any combination of name, email, and phoneNumber.
  /// If user is found in both Firestore and local storage, update both.
  /// If user is found in either Firestore or local storage, update only where it is found.
  Future<void> updateUserInformation({
    required String uid,
    String? name,
    String? email,
    String? phoneNumber,
  }) async {
    bool firestoreUpdated = false;
    bool localUpdated = false;

    // Try updating Firestore
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        Map<String, dynamic> updates = {};
        if (name != null) updates['name'] = name;
        if (email != null) updates['email'] = email;
        if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;

        if (updates.isNotEmpty) {
          await _firestore.collection('users').doc(uid).update(updates);
          firestoreUpdated = true;
        }
      }
    } catch (e) {
      print('Error updating Firestore: $e');
    }

    // Try updating local storage
    try {
      List<User> users = await getUsers();
      User? userToUpdate;

      for (var user in users) {
        if (user.uid == uid) {
          userToUpdate = user;
          break;
        }
      }

      if (userToUpdate != null) {
        // Create a new user object with updated fields
        User updatedUser = User(
          uid: userToUpdate.uid,
          name: name ?? userToUpdate.name,
          email: email ?? userToUpdate.email,
          phoneNumber: phoneNumber ?? userToUpdate.phoneNumber,
          notificationsEnabled: userToUpdate.notificationsEnabled,
          password: userToUpdate.password,
          profileImagePath: userToUpdate.profileImagePath,
        );

        await updateUser(updatedUser);
        localUpdated = true;
      }
    } catch (e) {
      print('Error updating local storage: $e');
    }

    // If user is not found in either Firestore or local storage, log an error or handle it
    if (!firestoreUpdated && !localUpdated) {
      print('User not found in both Firestore and local storage.');
    }
  }

  /// Update the current user's information in all `friends` subcollections
  Future<void> propagateFriendUpdates({
    required String userId,
    required String updatedName,
    required String updatedPhoneNumber,
  }) async {
    try {
      // Query all users who have this user as a friend
      final usersSnapshot = await _firestore.collection('users').get();

      WriteBatch batch = _firestore.batch();

      for (var userDoc in usersSnapshot.docs) {
        final friendsCollection = _firestore
            .collection('users')
            .doc(userDoc.id)
            .collection('friends');

        // Check if the current user exists in the friend's list by userId
        final querySnapshot = await friendsCollection
            .where('userId',
                isEqualTo: userId) // Use `userId` as a unique identifier
            .get();

        for (var friendDoc in querySnapshot.docs) {
          // Update the friend information
          batch.update(friendDoc.reference, {
            'name': updatedName,
            'phoneNumber': updatedPhoneNumber,
          });
        }
      }

      // Commit the batch update
      await batch.commit();
      print('Friends information updated successfully.');
    } catch (e) {
      print('Error propagating friend updates: $e');
    }
  }
}
