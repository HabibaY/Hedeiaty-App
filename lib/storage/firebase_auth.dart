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
    } catch (e) {
      rethrow; // Pass the error to the caller
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
      print("Fetching events for userId: $userId");

      // Step 1: Fetch user's events with their Firestore eId
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

      // Step 2: For each event, set up a listener on its 'gifts' collection
      for (var eventDoc in eventsSnapshot.docs) {
        final eId = eventDoc.id; // Firestore eId for the event
        print("Setting up listener for gifts under event: $eId");
        FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('events')
            .doc(eId)
            .collection('gifts')
            .snapshots()
            .listen((snapshot) {
          print("Raw snapshot data for event $eId: ${snapshot.docs}");

          for (var doc in snapshot.docs) {
            final giftData = doc.data();
            print("Gift Data: $giftData");
          }
        });

        FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('events')
            .doc(eId)
            .collection('gifts')
            .where('status', isEqualTo: true) // Match boolean true
            .snapshots()
            .listen((snapshot) async {
          print(
              "Received ${snapshot.docs.length} pledged gifts for event: $eId");

          for (var docChange in snapshot.docChanges) {
            if (docChange.type == DocumentChangeType.added) {
              final giftData = docChange.doc.data() as Map<String, dynamic>?;
              if (giftData != null) {
                print("Pledged gift found: ${giftData['name']}");

                // Show notification for the pledged gift
                await NotificationHelper.showGiftNotification({
                  'name': giftData['name'] ?? 'Unnamed Gift',
                  'friend_name': giftData['friend_name'] ?? 'A friend',
                });
              }
            }
          }
        });
      }
    } catch (e) {
      print("Error listening for pledged gifts: $e");
    }
  }
}
