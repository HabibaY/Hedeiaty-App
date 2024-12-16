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
    await _localStorageService.updateEvent(updatedEvent.toMap());
  }

  /// Delete an event by its ID
  Future<void> deleteEvent(int eventId) async {
    await _localStorageService.deleteEvent(eventId);
  }

  /// Fetch a single event by its ID (useful for editing)
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
          'eventId': event['id'],
        };

        // Publish event to Firestore and get Firestore's auto-generated ID
        DocumentReference eventRef = await _firestore
            .collection('users')
            .doc(userId)
            .collection('events')
            .add(eventData);
        String eventId = eventRef.id;

        // Fetch associated gifts for the event
        List<Gift> gifts = await GiftController().getGiftsForEvent(event['id']);
        for (var gift in gifts) {
          // Publish gift to Firestore
          DocumentReference giftRef = await eventRef.collection('gifts').add({
            'name': gift.name,
            'description': gift.description,
            'category': gift.category,
            'price': gift.price,
            'status': gift.status,
            'duedate': gift.dueDate
          });

          // Update Firestore ID for the gift locally
          await GiftController().setGiftFirestoreId(gift.id!, giftRef.id);
        }

        // Mark the event as published locally and update the `eId`
        await _localStorageService.markEventAsPublished(event['id'], eventId);
      }

      // Step 2: Handle newly added gifts for already published events
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
}
