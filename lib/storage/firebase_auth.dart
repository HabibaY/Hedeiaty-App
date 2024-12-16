import 'package:firebase_auth/firebase_auth.dart';
import '../storage/notification_service.dart';

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
//   void listenForPledgedGifts(String userId) {
//     gifts
//         .where('status', isEqualTo: 'Pledged')
//         .snapshots()
//         .listen((snapshot) async {
//       final events = await getEventsForUserFromFireStore(userId);
//       final eventIds = events?.map((event) => event.id).toSet() ?? {};

//       for (var docChange in snapshot.docChanges) {
//         if (docChange.type == DocumentChangeType.added) {
//           final data = docChange.doc.data() as Map<String, dynamic>;
//           final eventId = data['event_id'] as String;
//           print('Listening for pledged gifts...');
//           print('Gift pledged: $data');

//           // Check if the gift belongs to the user's events
//           if (eventIds.contains(eventId)) {
//             // Show the notification using the helper
//             await NotificationHelper.showGiftNotification(data);
//           }
//         }
//       }
//     });
//   }
}
