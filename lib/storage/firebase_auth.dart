import 'package:firebase_auth/firebase_auth.dart';
import '../storage/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Sign up with email and password
  Future<User?> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      rethrow; // Pass the error to the caller
    }
  }

  // Sign in with email and password
  Future<User?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No user found with this email.');
        case 'wrong-password':
          throw Exception('Invalid password. Please try again.');
        case 'invalid-email':
          throw Exception('Invalid email format.');
        default:
          throw Exception('Invalid Email/Password');
      }
    } catch (e) {
      throw Exception('An unknown error occurred.');
    }
  }

  // Sign out the current user
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      rethrow; // Pass the error to the caller
    }
  }

  // Fetch the current logged-in user
  User? getCurrentUser() {
    try {
      return _firebaseAuth.currentUser;
    } catch (e) {
      rethrow; // Pass the error to the caller
    }
  }

  void listenForPledgedGifts(String userId) async {
    try {
      print("Fetching notificationsEnabled setting for userId: $userId");

      // Step 1: Check if notifications are enabled for the user
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        print("User document does not exist for userId: $userId");
        return;
      }

      final notificationsEnabled =
          userDoc.data()?['notificationsEnabled'] ?? false;

      print("notificationsEnabled: $notificationsEnabled");

      if (!notificationsEnabled) {
        print("Notifications are disabled for userId: $userId");
        return; // Exit early if notifications are disabled
      }

      // Step 2: Fetch user's events
      final eventsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('events')
          .get();

      print("Fetched ${eventsSnapshot.docs.length} events for user: $userId");

      if (eventsSnapshot.docs.isEmpty) {
        print("No events found for user: $userId");
        return;
      }

      // Step 3: Listen for gift status changes (pledged/cancelled)
      for (var eventDoc in eventsSnapshot.docs) {
        final eId = eventDoc.id;
        print("Setting up listener for gifts under event: $eId");

        FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('events')
            .doc(eId)
            .collection('gifts')
            .snapshots()
            .listen((snapshot) async {
          for (var docChange in snapshot.docChanges) {
            final giftData = docChange.doc.data() as Map<String, dynamic>?;

            if (giftData == null) continue;

            // Check for newly pledged gifts
            if (docChange.type == DocumentChangeType.added &&
                giftData['status'] == true) {
              print("Pledged gift found: ${giftData['name']}");
              await NotificationHelper.showGiftNotification({
                'name': giftData['name'] ?? 'Unnamed Gift',
                'friend_name': giftData['friend_name'] ?? 'A friend',
              });
            }

            // Check for cancelled pledges
            if ((docChange.type == DocumentChangeType.modified &&
                    giftData['status'] == false) ||
                docChange.type == DocumentChangeType.removed) {
              print("Pledge cancelled for gift: ${giftData['name']}");
              await NotificationHelper.showPledgeCancelledNotification({
                'name': giftData['name'] ?? 'Unnamed Gift',
                'friend_name': giftData['friend_name'] ?? 'A friend',
              });
            }
          }
        });
      }
    } catch (e) {
      print("Error listening for pledged gifts: $e");
    }
  }
}
