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
    String? imagePath,
    String? gId,
    required int eventId,
  }) async {
    final gift = Gift(
      name: name,
      description: description,
      category: category,
      price: price,
      status: status,
      dueDate: dueDate,
      imagePath: imagePath,
      gId: gId,
      eventId: eventId,
    );

    // Insert into local DB
    final giftId = await _localStorageService.insertGift(gift.toMap());

    print("Inserted Gift ID: $giftId");

    // Debugging: Check returned ID
    if (giftId != 0) {
      print("Gift inserted successfully: ID=$giftId, Name=$name");
    } else {
      print("Failed to insert gift into local DB.");
    }
  }

  Future<List<Gift>> getGifts() async {
    final giftsMap = await _localStorageService.getGifts();
    print("Fetched gifts from local DB: $giftsMap"); // Debug print

    return giftsMap.map((map) {
      final gift = Gift.fromMap(map);
      print("Parsed Gift: ID=${gift.id}, Name=${gift.name}"); // Debug print
      return gift;
    }).toList();
  }

  Future<List<Gift>> getGiftsForEvent(int eventId) async {
    final giftsMap = await _localStorageService.getGiftsForEvent(eventId);
    return giftsMap.map((map) => Gift.fromMap(map)).toList();
  }

  Future<Gift?> getGiftById(int id) async {
    print("Querying local DB for Gift with ID: $id");
    final db = await _localStorageService.database;
    final result = await db.query(
      'gifts',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      print("Gift found: ${result.first}");
      return Gift.fromMap(result.first);
    }
    print("No gift found for ID: $id");
    return null;
  }

  Future<void> updateGift(Gift gift) async {
    final db = await _localStorageService.database;

    if (gift.id == null) {
      print("Error: Gift ID is null, cannot update locally.");
      return;
    }

    // Step 1: Update the local database
    final rowsAffected = await db.update(
      'gifts',
      gift.toMap(),
      where: 'id = ?',
      whereArgs: [gift.id],
    );

    if (rowsAffected > 0) {
      print("Gift updated locally: ID=${gift.id}");

      // Step 2: If Firestore ID exists, update Firestore
      if (gift.gId != null) {
        final userId = await _eventController.getUserIdForEvent(gift.eventId);
        final eid = await _eventController.getEventEid(gift.eventId);
        if (userId != null) {
          try {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('events')
                .doc(eid)
                .collection('gifts')
                .doc(gift.gId)
                .update({
              'giftId': gift.id,
              'imagePath': gift.imagePath,
              'dueDate': gift.dueDate,
              'name': gift.name,
              'description': gift.description,
              'category': gift.category,
              'price': gift.price,
              'status': gift.status,
            });
            print("Gift updated successfully in Firestore: gId=${gift.gId}");
          } catch (e) {
            print("Error updating gift in Firestore: $e");
          }
          print("Gift updated in Firestore: gId=${gift.gId}");
        } else {
          print("Error: User ID not found for event ID: ${gift.eventId}");
        }
      }
    } else {
      print("gId is null. Updating gift locally only...");

      // Create a new Gift object for local update
      final updatedGift = Gift(
        id: gift.id, // Local ID
        name: gift.name,
        description: gift.description,
        category: gift.category,
        price: gift.price,
        status: gift.status,
        dueDate: gift.dueDate,
        imagePath: gift.imagePath,
        gId: null, // Ensure gId remains null
        eventId: gift.eventId,
      );

      // Update the gift locally using the storage service
      await _localStorageService.updateGift(updatedGift.toMap());
      print("Gift updated locally with gId = null: ID=${updatedGift.id}");
      return;
    }
  }

  Future<void> updateGiftFirestore(Gift gift) async {
    final db = await LocalStorageService().database;

    // Check if the gift already exists in the local database by Firestore ID (gId)
    final existingGift = await db.query(
      'gifts',
      where: 'gId = ?', // Match using gId
      whereArgs: [gift.gId],
    );

    if (existingGift.isNotEmpty) {
      // If gift exists, update it
      final localGiftId = existingGift.first['id'];
      print("Gift exists. Updating ID: $localGiftId");

      await db.update(
        'gifts',
        {
          'id': localGiftId, // Retain the local DB ID
          'name': gift.name,
          'description': gift.description,
          'category': gift.category,
          'price': gift.price,
          'status': gift.status ? 1 : 0,
          'dueDate': gift.dueDate,
          'imagePath': gift.imagePath,
          'gId': gift.gId,
        },
        where: 'id = ?',
        whereArgs: [localGiftId],
      );

      print("Gift updated in DB: ${gift.name}");
    } else {
      // If gift does not exist, insert it
      print("Inserting new gift into DB: ${gift.name}");
      await db.insert(
        'gifts',
        {
          'name': gift.name,
          'description': gift.description,
          'category': gift.category,
          'price': gift.price,
          'status': gift.status ? 1 : 0,
          'dueDate': gift.dueDate,
          'imagePath': gift.imagePath,
          'gId': gift.gId,
          'eventId': gift.eventId,
        },
      );
      print("Gift inserted in DB: ${gift.name}");
    }
  }

  Future<String?> getFirestoreId(int localGiftId) async {
    final gift = await _localStorageService.getGiftById(localGiftId);
    return gift?['gId'];
  }

  Future<void> deleteGift(int giftId) async {
    final gift = await getGiftById(giftId);

    if (gift == null) {
      print("Gift not found in the local database.");
      return;
    }

    try {
      if (gift.gId != null) {
        // Step 1: Fetch userId for the event
        final userId = await _eventController.getUserIdForEvent(gift.eventId);
        if (userId != null) {
          print(
              "Deleting gift from Firestore: users/$userId/events/${gift.eventId}/gifts/${gift.gId}");

          // Delete the gift document from Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('events')
              .doc(gift.eventId.toString())
              .collection('gifts')
              .doc(gift.gId)
              .delete();

          print("Gift deleted from Firestore: ${gift.gId}");
        } else {
          print("Error: User ID not found for event ID: ${gift.eventId}");
        }
      } else {
        if (gift.status) {
          // Check if gift is pledged (status == true)
          print("Cannot delete pledged gift: ${gift.gId}");
          return;
        }
        await _localStorageService.deleteGift(giftId);
        print('Gift deleted locally: $giftId');
      }

      // Step 2: Delete the gift from the local database
      await _localStorageService.deleteGift(gift.id!);
      print("Gift deleted locally: ${gift.id}");
    } catch (e) {
      print("Error deleting gift: $e");
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
        imagePath: gift.imagePath,
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

  // /// Sync Firestore gifts with local DB
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
        final firestoreGifts = await Future.wait(snapshot.docs.map((doc) async {
          final data = doc.data();

          // Check local database for existing record with matching Firestore gId
          final localGift = await _localStorageService.getGiftByGId(doc.id);

          // Parse gift with local ID if available
          final gift = Gift(
            id: localGift?.id, // Use the local DB ID if it exists
            gId: doc.id, // Firestore document ID
            name: data['name'] ?? '',
            description: data['description'] ?? '',
            category: data['category'] ?? '',
            price: (data['price'] is num) ? data['price'].toDouble() : 0.0,
            status: (data['status'] is bool) ? data['status'] : false,
            dueDate: data['dueDate'] ?? '',
            imagePath: data['imagePath'],
            eventId: eventId,
          );

          print(
              "Parsed Gift: Local ID=${gift.id}, Firestore gId=${gift.gId}, Name=${gift.name}");
          return gift;
        }).toList());

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

  /// Sync Firestore gifts with local DB
  // Stream<List<Gift>> fetchFirestoreGifts(int eventId) async* {
  //   try {
  //     String? userId = await _eventController.getUserIdForEvent(eventId);
  //     String? eId = await _eventController.getEventEid(eventId);

  //     // If userId is not found locally, fetch from Firestore
  //     if (userId == null) {
  //       print(
  //           "Local userId not found for eventId: $eventId. Fetching from Firestore...");
  //       userId = await _fetchUserIdFromFirestore(eventId);
  //       if (userId == null) {
  //         print("No userId found in Firestore. Cannot fetch gifts.");
  //         yield [];
  //         return;
  //       }
  //     }

  //     // If eId is not found locally, fetch event IDs from Firestore
  //     if (eId == null) {
  //       print(
  //           "Local eId not found for eventId: $eventId. Fetching eventIds from Firestore...");
  //       final firestoreEventIds = await _fetchEventIdsForUser(userId);
  //       if (firestoreEventIds.isEmpty) {
  //         print("No events found in Firestore for userId: $userId");
  //         yield [];
  //         return;
  //       }

  //       // Use the first event ID (or adjust based on your use case)
  //       eId = firestoreEventIds.first;
  //     }

  //     print("Querying Firestore path: users/$userId/events/$eId/gifts");

  //     // Fetch gifts from Firestore
  //     yield* FirebaseFirestore.instance
  //         .collection("users")
  //         .doc(userId)
  //         .collection('events')
  //         .doc(eId)
  //         .collection('gifts')
  //         .snapshots()
  //         .asyncMap((snapshot) async {
  //       print("Received snapshot with ${snapshot.docs.length} documents.");

  //       final firestoreGifts = snapshot.docs.map((doc) {
  //         final data = doc.data();
  //         return Gift(
  //           id: null,
  //           gId: doc.id,
  //           name: data['name'] ?? '',
  //           description: data['description'] ?? '',
  //           category: data['category'] ?? '',
  //           price: (data['price'] is num) ? data['price'].toDouble() : 0.0,
  //           status: (data['status'] is bool) ? data['status'] : false,
  //           dueDate: data['duedate'] ?? '',
  //           eventId: eventId,
  //         );
  //       }).toList();

  //       print("Gifts fetched from Firestore: ${firestoreGifts.length}");
  //       return firestoreGifts;
  //     });
  //   } catch (e) {
  //     print("Error fetching Firestore gifts: $e");
  //     yield [];
  //   }
  // }

// Helper method to fetch userId from Firestore
  Future<String?> _fetchUserIdFromFirestore(int eventId) async {
    try {
      final usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      for (var userDoc in usersSnapshot.docs) {
        final eventsSnapshot = await userDoc.reference
            .collection('events')
            .where('id', isEqualTo: eventId)
            .get();

        if (eventsSnapshot.docs.isNotEmpty) {
          print(
              "Found userId in Firestore: ${userDoc.id} for eventId: $eventId");
          return userDoc.id;
        }
      }
      return null;
    } catch (e) {
      print("Error fetching userId from Firestore: $e");
      return null;
    }
  }

// Helper method to fetch all eventIds for a user from Firestore
  Future<List<String>> _fetchEventIdsForUser(String userId) async {
    try {
      final eventsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('events')
          .get();

      return eventsSnapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print("Error fetching eventIds for userId: $userId - $e");
      return [];
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
            imagePath: '',
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
  Future<Gift?> getGiftByFirestoreId(int eventId, int localGiftId) async {
    try {
      final userId = await _eventController.getUserIdForEvent(eventId);
      final eId = await _eventController.getEventEid(eventId);

      if (userId != null && eId != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('events')
            .doc(eId)
            .collection('gifts')
            .get();

        for (var doc in snapshot.docs) {
          if (doc.data()['id'] == localGiftId) {
            final data = doc.data();
            return Gift(
              id: localGiftId,
              gId: doc.id,
              name: data['name'] ?? '',
              description: data['description'] ?? '',
              category: data['category'] ?? '',
              price: (data['price'] is num) ? data['price'].toDouble() : 0.0,
              status: data['status'] ?? false,
              dueDate: data['dueDate'] ?? '',
              imagePath: data['imagePath'],
              eventId: eventId,
            );
          }
        }
      }
    } catch (e) {
      print("Error fetching gift by Firestore ID: $e");
    }
    return null;
  }
}
