import '../models/event.dart';
import '../storage/local_storage_service.dart';

class EventController {
  final LocalStorageService _localStorageService = LocalStorageService();

  /// Add a new event
  Future<void> addEvent({
    required String name,
    required String date,
    required String location,
    required String description,
    required String category,
    required String userId,
  }) async {
    Event event = Event(
      name: name,
      date: date,
      location: location,
      description: description,
      category: category,
      userId: userId,
    );
    await _localStorageService.insertEvent(event.toMap());
  }

  /// Fetch all events for a specific user
  Future<List<Event>> getEventsForUser(String userId) async {
    List<Map<String, dynamic>> eventsMap =
        await _localStorageService.getEventsForUser(userId);
    return eventsMap.map((map) => Event.fromMap(map)).toList();
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
}
