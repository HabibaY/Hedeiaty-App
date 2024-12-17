import '../models/gift.dart';
import '../storage/local_storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'event_controller.dart'; // Import EventController
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class GiftController {
  final LocalStorageService _localStorageService = LocalStorageService();
  final EventController _eventController = EventController();

  Future<void> addGift({
    required String name,
    required String description,
    required String category,
    required double price,
    required bool status,
    required String dueDate,
    String? gId, // Optional Firestore ID
    required int eventId,
  }) async {
    final gift = Gift(
      name: name,
      description: description,
      category: category,
      price: price,
      status: status,
      dueDate: dueDate,
      gId: gId, // Pass Firestore ID or null
      eventId: eventId,
    );
    await _localStorageService.insertGift(gift.toMap());
  }

  Future<List<Gift>> getGifts() async {
    final giftsMap = await _localStorageService.getGifts();
    return giftsMap.map((map) => Gift.fromMap(map)).toList();
  }

  Future<List<Gift>> getGiftsForEvent(int eventId) async {
    final giftsMap = await _localStorageService.getGiftsForEvent(eventId);
    return giftsMap.map((map) => Gift.fromMap(map)).toList();
  }

  Future<Gift?> getGiftById(int giftId) async {
    final giftsMap = await _localStorageService.getGiftById(giftId);
    if (giftsMap != null) {
      return Gift.fromMap(giftsMap);
    }
    return null;
  }

  Future<void> updateGift(Gift updatedGift) async {
    await _localStorageService.updateGift(updatedGift.toMap());
  }

  Future<void> updateGiftFirestore(Gift gift) async {
    final db = await LocalStorageService().database;

    // Check if the gift exists in the local database
    final existingGift = await db.query(
      'gifts',
      where: 'gId = ?', // Match using gId (Firestore document ID)
      whereArgs: [gift.gId],
    );

    if (existingGift.isNotEmpty) {
      // Update the existing record
      await db.update(
        'gifts',
        {
          'name': gift.name,
          'description': gift.description,
          'category': gift.category,
          'price': gift.price,
          'status': gift.status ? 1 : 0,
          'dueDate': gift.dueDate,
          'gId': gift.gId,
        },
        where: 'gId = ?', // Match using Firestore ID
        whereArgs: [gift.gId],
      );
      print("Gift updated in DB: ${gift.name}");
    } else {
      // Insert new record if it doesn't exist
      await db.insert(
        'gifts',
        {
          'name': gift.name,
          'description': gift.description,
          'category': gift.category,
          'price': gift.price,
          'status': gift.status ? 1 : 0,
          'dueDate': gift.dueDate,
          'gId': gift.gId,
          'eventId': gift.eventId,
        },
      );
      print("Gift inserted in DB: ${gift.name}");
    }
  }

  Future<void> deleteGift(int giftId) async {
    final gift = await getGiftById(giftId); // Retrieve gift details to get gId

    if (gift == null) {
      print("Gift not found in the local database.");
      return;
    }

    if (gift.status) {
      // Check if gift is pledged (status == true)
      print("Cannot delete pledged gift: ${gift.gId}");
      return;
    }

    try {
      // Step 1: Find Firestore event document ID
      final eventQuerySnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('eventId', isEqualTo: gift.eventId)
          .get();

      if (eventQuerySnapshot.docs.isEmpty) {
        print("No Firestore event document found for eventId: ${gift.eventId}");
      } else if (gift.gId != null) {
        // Step 2: Delete gift from Firestore
        final eventDocId = eventQuerySnapshot.docs.first.id;

        await FirebaseFirestore.instance
            .collection('events')
            .doc(eventDocId)
            .collection('gifts')
            .doc(gift.gId)
            .delete();

        print('Gift deleted from Firestore: ${gift.gId}');
      }

      // Step 3: Delete gift from local database
      await _localStorageService.deleteGift(giftId);
      print('Gift deleted locally: $giftId');
    } catch (e) {
      print('Error deleting gift: $e');
    }
  }

  Future<void> setGiftFirestoreId(int giftId, String gId) async {
    final gift = await getGiftById(giftId);
    if (gift != null) {
      final updatedGift = Gift(
        id: gift.id,
        name: gift.name,
        description: gift.description,
        category: gift.category,
        price: gift.price,
        status: gift.status,
        dueDate: gift.dueDate,
        gId: gId, // Update Firestore ID
        eventId: gift.eventId,
      );
      await updateGift(updatedGift);
    }
  }

  /// Deletes all gifts associated with a specific event ID
  Future<void> deleteGiftsForEvent(int eventId) async {
    try {
      // Step 1: Fetch all gifts associated with the event
      List<Gift> gifts = await getGiftsForEvent(eventId);
      print("Found ${gifts.length} gifts to delete for event ID: $eventId");

      // Step 2: Delete each gift
      for (var gift in gifts) {
        await _localStorageService.deleteGift(gift.id!);
        print("Deleted gift with ID: ${gift.id}");
      }
    } catch (e) {
      print("Error deleting gifts for event ID: $eventId - $e");
      rethrow;
    }
  }

  /// Sync Firestore gifts with local DB
  Stream<List<Gift>> fetchFirestoreGifts(int eventId) async* {
    try {
      // Step 1: Get Firestore Event Document ID
      // Step 1: Get userId from EventController (which fetches from LocalStorageService)
      final userId = await _eventController.getUserIdForEvent(eventId);
      if (userId == null) {
        print("Error: Could not find userId for eventId: $eventId");
        yield [];
        return;
      }

      final eId = await _eventController.getEventEid(eventId);

      if (eId == null) {
        print("No Firestore eId found for eventId: $eventId");
        yield await getGiftsForEvent(eventId); // Return local gifts only
        return;
      }
      // Step 2: Debug Log - Confirm the Firestore path being queried
      print("Querying Firestore path: events/$eId/gifts");

      // Step 2: Set up Firestore Listener
      yield* FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection('events')
          .doc(eId)
          .collection('gifts')
          .snapshots()
          .asyncMap((snapshot) async {
        print("Received snapshot with ${snapshot.docs.length} documents.");

        // Log raw Firestore data
        snapshot.docs.forEach((doc) {
          print("Document ID: ${doc.id}, Data: ${doc.data()}");
        });

        // Step 3: Parse Firestore Gifts
        final firestoreGifts = snapshot.docs.map((doc) {
          final data = doc.data();

          return Gift(
            id: null,
            gId: doc.id,
            name: data['name'] ?? '',
            description: data['description'] ?? '',
            category: data['category'] ?? '',
            price: (data['price'] is num) ? data['price'].toDouble() : 0.0,
            status: (data['status'] is bool)
                ? data['status']
                : (data['status'] == true || data['status'] == "true"),
            dueDate: data['duedate'] ?? '',
            eventId: eventId,
          );
        }).toList();

        // Step 4: Update Local Database
        print("Updating Local DB with Firestore Data...");
        for (var gift in firestoreGifts) {
          print(
              "Syncing Gift - gId: ${gift.gId}, Name: ${gift.name}, Status: ${gift.status}");
          await updateGiftFirestore(gift); // Sync to local DB
        }
        print("Local DB Updated Successfully");

        // Step 5: Fetch Combined Gifts
        final localGifts = await getGiftsForEvent(eventId);

        final combinedGifts = <String?, Gift>{};

        // Add Firestore gifts
        for (var gift in firestoreGifts) {
          combinedGifts[gift.gId] = gift;
        }

        // Add local gifts that don't exist in Firestore
        for (var gift in localGifts) {
          if (gift.gId == null || !combinedGifts.containsKey(gift.gId)) {
            combinedGifts[gift.gId] = gift;
          }
        }

        return combinedGifts.values.toList();
      });
    } catch (e) {
      print("Error fetching Firestore gifts: $e");
      yield [];
    }
  }

  Future<void> syncGiftsWithFirestore(
      int eventId, List<Gift> firestoreGifts) async {
    try {
      // Fetch local gifts
      final localGifts = await getGiftsForEvent(eventId);

      // Step 1: Compare and sync Firestore gifts
      for (var firestoreGift in firestoreGifts) {
        final localGift = localGifts.firstWhere(
          (gift) => gift.gId == firestoreGift.gId, // Compare gId directly
          orElse: () => Gift(
            id: null,
            gId: firestoreGift.gId, // Use Firestore gId
            name: '',
            description: '',
            category: '',
            price: 0.0,
            status: false,
            dueDate: '',
            eventId: firestoreGift.eventId,
          ),
        );

        // If the gifts are different, update the local DB
        if (_isGiftDifferent(firestoreGift, localGift)) {
          print("Syncing updated gift: ${firestoreGift.name}");
          await updateGift(firestoreGift);
        }
      }

      // Step 2: Handle gifts in local DB but not in Firestore
      for (var localGift in localGifts) {
        final existsInFirestore =
            firestoreGifts.any((gift) => gift.gId == localGift.gId);
        if (!existsInFirestore) {
          print(
              "Gift not found in Firestore, retaining in local DB: ${localGift.name}");
        }
      }
    } catch (e) {
      print("Error syncing gifts: $e");
    }
  }

  bool _isGiftDifferent(Gift firestoreGift, Gift localGift) {
    return firestoreGift.name != localGift.name ||
        firestoreGift.description != localGift.description ||
        firestoreGift.category != localGift.category ||
        firestoreGift.price != localGift.price ||
        firestoreGift.status != localGift.status ||
        firestoreGift.dueDate != localGift.dueDate;
  }

  // Stream<List<Gift>> streamFirestoreGifts(int eventId) async* {
  //   try {
  //     final eId = await _eventController
  //         .getEventEid(eventId); // Fetch Firestore event document ID
  //     if (eId == null) {
  //       print("No Firestore eId found for eventId $eventId.");
  //       yield [];
  //       return;
  //     }

  //     // Real-time Firestore listener
  //     yield* FirebaseFirestore.instance
  //         .collection('events')
  //         .doc(eId)
  //         .collection('gifts')
  //         .snapshots()
  //         .asyncMap((snapshot) async {
  //       final firestoreGifts = snapshot.docs.map((doc) {
  //         final data = doc.data();
  //         return Gift(
  //           id: null,
  //           gId: doc.id,
  //           name: data['name'] ?? '',
  //           description: data['description'] ?? '',
  //           category: data['category'] ?? '',
  //           price: (data['price'] is num) ? data['price'].toDouble() : 0.0,
  //           status: data['status'] ?? false,
  //           dueDate: data['duedate'] ?? '',
  //           eventId: eventId,
  //         );
  //       }).toList();

  //       // Sync Firestore data with local storage
  //       await syncGiftsWithFirestore(eventId);

  //       return firestoreGifts;
  //     });
  //   } catch (e) {
  //     print("Error streaming Firestore gifts: $e");
  //     yield [];
  //   }
  // }
}
