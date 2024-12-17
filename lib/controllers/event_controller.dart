import '../models/event.dart';
import '../storage/local_storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gift.dart';
import '../controllers/gift_controller.dart';

class EventController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalStorageService _localStorageService = LocalStorageService();

  /// Add a new event
  /// Add a new event
  Future<void> addEvent({
    required String name,
    required String date,
    required String location,
    required String description,
    required String category,
    String? eId, // Optional Firestore ID
    required bool isPublished,
    required String userId,
  }) async {
    Event event = Event(
      name: name,
      date: date,
      location: location,
      description: description,
      category: category,
      eId: eId, // Pass Firestore ID or null
      isPublished: isPublished,
      userId: userId,
    );
    await _localStorageService.insertEvent(event.toMap());
  }

  /// Fetch all events for a specific user
  Future<List<Event>> getEventsForUser(String userId) async {
    try {
      // Try fetching events from local storage
      List<Map<String, dynamic>> eventsMap =
          await _localStorageService.getEventsForUser(userId);

      if (eventsMap.isNotEmpty) {
        print('Fetched ${eventsMap.length} events locally for user $userId.');
        return eventsMap.map((map) => Event.fromMap(map)).toList();
      } else {
        print(
            'No events found locally for user $userId. Fetching from Firestore...');
      }
    } catch (e) {
      print('Error fetching events from local storage: $e');
    }

    // If local fetch fails or no events are found, fetch events from Firestore
    try {
      QuerySnapshot firestoreSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('events')
          .get();

      if (firestoreSnapshot.docs.isEmpty) {
        print('No events found in Firestore for user $userId.');
        return [];
      }

      print(
          'Fetched ${firestoreSnapshot.docs.length} events from Firestore for user $userId.');

      // Map Firestore documents to Event objects
      List<Event> firestoreEvents = firestoreSnapshot.docs.map((doc) {
        return Event.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id, userId);
      }).toList();

      // // Optionally store events locally
      // for (var event in firestoreEvents) {
      //   print('Storing event locally: ${event.toMap()}');
      //   await _localStorageService.insertEvent(event.toMap());
      // }

      return firestoreEvents;
    } catch (e) {
      print('Error fetching events from Firestore: $e');
      return [];
    }
  }

  /// Update an existing event
  Future<void> updateEvent(Event updatedEvent) async {
    try {
      // Step 1: Update local database
      await _localStorageService.updateEvent(updatedEvent.toMap());
      print('Event updated locally: ${updatedEvent.toMap()}');

      // Step 2: Update Firestore if the event is published
      if (updatedEvent.isPublished && updatedEvent.eId != null) {
        await _firestore
            .collection('users')
            .doc(updatedEvent.userId)
            .collection('events')
            .doc(updatedEvent.eId) // Firestore ID for the event
            .update({
          'name': updatedEvent.name,
          'date': updatedEvent.date,
          'location': updatedEvent.location,
          'description': updatedEvent.description,
          'category': updatedEvent.category,
        });
        print('Event updated in Firestore: ${updatedEvent.eId}');
      } else {
        print('cannot update firestore');
      }
    } catch (e) {
      print('Error updating event: $e');
      rethrow;
    }
  }

  /// Delete an event by its ID
  /// Delete an event by its ID (and associated gifts if not published)
  Future<bool> deleteEvent(int eventId) async {
    try {
      // Step 1: Retrieve the event by ID
      Event? event = await getEventById(eventId);

      if (event != null) {
        if (event.eId == null) {
          // Event is not published → delete associated gifts
          print("Deleting associated gifts for event ID: $eventId");
          await GiftController().deleteGiftsForEvent(eventId);

          // Delete the event from the local database
          await _localStorageService.deleteEvent(eventId);
          print("Event deleted locally: $eventId");
          return true; // Deletion successful
        } else {
          print("Event is published and cannot be deleted: $eventId");
          return false; // Deletion not allowed
        }
      } else {
        print("Event not found for ID: $eventId");
        return false; // Event does not exist
      }
    } catch (e) {
      print("Error deleting event: $e");
      rethrow;
    }
  }

  /// Fetch a single event by its ID (useful for editing)
  Future<String?> getEventEid(int eventId) async {
    try {
      // Fetch raw event maps from local storage
      final eventMaps = await _localStorageService.getEvents();

      // Convert raw maps to Event objects
      final events = eventMaps.map((map) => Event.fromMap(map)).toList();

      // Find the event with matching eventId
      final event = events.firstWhere(
        (event) => event.id == eventId,
        orElse: () => Event(
          // Return an empty Event object instead of null
          id: -1,
          eId: null,
          userId: '',
          name: '',
          location: '',
          description: '',
          category: '',
          date: '',
          isPublished: false,
        ),
      );

      // Check if the found event has a valid eId
      if (event.id != -1 && event.eId != null) {
        print("Found Firestore eId for eventId $eventId: ${event.eId}");
        return event.eId; // Return Firestore document ID (eId)
      } else {
        print("No eId found for eventId: $eventId");
        return null;
      }
    } catch (e) {
      print("Error fetching eId for eventId $eventId: $e");
      return null;
    }
  }

  Future<Event?> getEventById(int eventId) async {
    Map<String, dynamic>? eventMap =
        await _localStorageService.getEventById(eventId);
    return eventMap != null ? Event.fromMap(eventMap) : null;
  }

  /// Publish events and their associated gifts
  Future<void> publishEventsAndGifts(String userId) async {
    try {
      // Step 1: Fetch unpublished events
      List<Map<String, dynamic>> localEvents =
          await _localStorageService.getUnpublishedEvents();

      for (var event in localEvents) {
        // Prepare event data for Firestore
        Map<String, dynamic> eventData = {
          'name': event['name'],
          'date': event['date'],
          'location': event['location'],
          'description': event['description'],
          'category': event['category'],
          'eventId': event['id'], // Local database ID
        };

        String? eventId; // Firestore document ID

        // Check if the event is already published (eId exists)
        if (event['eId'] != null) {
          // Update the existing Firestore document
          eventId = event['eId'];
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('events')
              .doc(eventId)
              .update(eventData);

          print('Updated event in Firestore: $eventId');
        } else {
          // Publish event to Firestore and get Firestore's auto-generated ID
          DocumentReference eventRef = await _firestore
              .collection('users')
              .doc(userId)
              .collection('events')
              .add(eventData);
          eventId = eventRef.id;

          // Mark the event as published locally and update the `eId`
          await _localStorageService.markEventAsPublished(event['id'], eventId);
          print('Created new event in Firestore: $eventId');
        }

        // Step 2: Fetch associated gifts for the event
        List<Gift> gifts = await GiftController().getGiftsForEvent(event['id']);
        for (var gift in gifts) {
          if (gift.gId == null) {
            // Publish gift to Firestore
            DocumentReference giftRef = await _firestore
                .collection('users')
                .doc(userId)
                .collection('events')
                .doc(eventId)
                .collection('gifts')
                .add({
              'name': gift.name,
              'description': gift.description,
              'category': gift.category,
              'price': gift.price,
              'status': gift.status,
              'duedate': gift.dueDate,
            });

            // Update Firestore ID for the gift locally
            await GiftController().setGiftFirestoreId(gift.id!, giftRef.id);
          }
        }
      }

      // Step 3: Handle newly added gifts for already published events
      List<Map<String, dynamic>> publishedEvents =
          await _localStorageService.getPublishedEvents();
      for (var event in publishedEvents) {
        // Fetch gifts for the event
        List<Gift> gifts = await GiftController().getGiftsForEvent(event['id']);

        for (var gift in gifts) {
          if (gift.gId == null) {
            // Publish the gift to Firestore if it doesn't have a Firestore ID
            DocumentReference giftRef = await _firestore
                .collection('users')
                .doc(userId)
                .collection('events')
                .doc(event['eId'])
                .collection('gifts')
                .add({
              'name': gift.name,
              'description': gift.description,
              'category': gift.category,
              'price': gift.price,
              'status': gift.status,
              'duedate': gift.dueDate,
            });

            // Update Firestore ID for the gift locally
            await GiftController().setGiftFirestoreId(gift.id!, giftRef.id);
          }
        }
      }
    } catch (e) {
      print('Error publishing events and gifts: $e');
      rethrow;
    }
  }

  Future<String?> getUserIdForEvent(int eventId) async {
    try {
      final userId = await _localStorageService.getUserIdForEvent(eventId);
      if (userId != null) {
        print("Found userId: $userId for eventId: $eventId");
        return userId;
      } else {
        print("UserId not found for eventId: $eventId");
        return null;
      }
    } catch (e) {
      print("Error in EventController fetching userId: $e");
      return null;
    }
  }
}
