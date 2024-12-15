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
    // Create a User object with all fields
    User user = User(
      uid: uid,
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      notificationsEnabled: notificationsEnabled,
      password: password,
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
      // Add user document with essential details
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'notificationsEnabled': notificationsEnabled,
        'password': password,
        'profileImagePath': profileImagePath,
      });

      // Avoid creating placeholder events, gifts, or friends collections
      print("User document added to Firestore successfully.");
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

  /// Fetch user data from Firestore by UID
  Future<User?> fetchUserFromFirestore(String uid) async {
    try {
      // Fetch the user document from Firestore
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        if (userData != null) {
          // Convert Firestore data into a User object
          return User(
            uid: uid,
            name: userData['name'] ?? '',
            email: userData['email'] ?? '',
            phoneNumber: userData['phoneNumber'] ?? '',
            notificationsEnabled: userData['notificationsEnabled'] ?? true,
            password: userData['password'] ?? '',
            profileImagePath: userData['profileImagePath'] ?? '',
          );
        }
      }
    } catch (e) {
      print('Error fetching user from Firestore: $e');
    }
    return null; // Return null if the user is not found
  }

  // Update the profile image path in local storage
// Update the profile image path in local storage
  Future<void> updateUserProfileImage(String uid, String newImagePath) async {
    try {
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
        print('User updated locally: ${updatedUser.toMap()}');
      } else {
        print('User not found locally, skipping local update.');
      }
    } catch (e) {
      print('Error updating local storage: $e');
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

      User? userToUpdate = users.cast<User?>().firstWhere(
            (user) => user?.uid == uid,
            orElse: () => null,
          );

      for (var user in users) {
        if (user.uid == uid) {
          userToUpdate = user;
          break;
        }
      }

      if (userToUpdate != null) {
        // Create a new user object with updated fields
        User updatedUser = User(
          id: userToUpdate.id,
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
        print('User updated locally: ${updatedUser.toMap()}');
      } else {
        print('User not found locally, skipping local update.');
      }
    } catch (e) {
      print('Error updating local storage: $e');
    }

    // If user is not found in either Firestore or local storage, log an error or handle it
    if (!firestoreUpdated && !localUpdated) {
      print('User not found in both Firestore and local storage.');
    }
  }

  Future<void> updateNotificationPreference(
      String uid, bool notificationsEnabled) async {
    bool firestoreUpdated = false;
    bool localUpdated = false;

    // Update Firestore
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        await _firestore.collection('users').doc(uid).update({
          'notificationsEnabled': notificationsEnabled,
        });
        firestoreUpdated = true;
      }
    } catch (e) {
      print('Error updating Firestore notifications: $e');
    }

    // Update local storage
    try {
      List<User> users = await getUsers();
      User? userToUpdate = users.cast<User?>().firstWhere(
            (user) => user?.uid == uid,
            orElse: () => null,
          );

      if (userToUpdate != null) {
        // Create an updated user object
        User updatedUser = User(
          id: userToUpdate.id,
          uid: userToUpdate.uid,
          name: userToUpdate.name,
          email: userToUpdate.email,
          phoneNumber: userToUpdate.phoneNumber,
          notificationsEnabled: notificationsEnabled, // Updated notifications
          password: userToUpdate.password,
          profileImagePath: userToUpdate.profileImagePath,
        );

        await updateUser(updatedUser);
        localUpdated = true;
        print(
            'Notification preference updated locally: ${updatedUser.toMap()}');
      } else {
        print('User not found locally, skipping local update.');
      }
    } catch (e) {
      print('Error updating local storage notifications: $e');
    }

    if (!firestoreUpdated && !localUpdated) {
      print('Notification update failed in both Firestore and local storage.');
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

  /// Publish local events and gifts to Firestore
  Future<void> publishEventsToFirestore(String userId) async {
    try {
      // Fetch local events from the database
      final localEvents = await _localStorageService.getEventsForUser(userId);

      for (var event in localEvents) {
        // Add the event to Firestore under the user's events subcollection
        final eventRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('events')
            .doc(event['id']
                .toString()); // Use the local event ID as the Firestore doc ID

        await eventRef.set({
          'name': event['name'],
          'date': event['date'],
          'location': event['location'],
          'description': event['description'],
          'category': event['category'],
        });

        // Fetch gifts associated with this event from the local database
        final localGifts =
            await _localStorageService.getGiftsForEvent(event['id']);

        // Add gifts to the Firestore `gifts` subcollection under this event
        for (var gift in localGifts) {
          await eventRef.collection('gifts').doc(gift['id'].toString()).set({
            'name': gift['name'],
            'description': gift['description'],
            'category': gift['category'],
            'price': gift['price'],
            'status': gift['status'],
          });
        }
      }

      print("All events and gifts have been published successfully.");
    } catch (e) {
      print("Error publishing events: $e");
      rethrow;
    }
  }
}
