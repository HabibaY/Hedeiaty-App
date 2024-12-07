import '../models/event.dart';
import '../services/local_storage_service.dart';

class EventController {
  final LocalStorageService _localStorageService = LocalStorageService();

  Future<void> addEvent(String name, String date, String location,
      String description, String category, String status, int userId) async {
    Event event = Event(
      name: name,
      date: date,
      location: location,
      description: description,
      category: category,
      status: status,
      userId: userId,
    );
    await _localStorageService.insertEvent(event.toMap());
  }

  Future<List<Event>> getEvents() async {
    List<Map<String, dynamic>> eventsMap =
        await _localStorageService.getEvents();
    return eventsMap.map((map) => Event.fromMap(map)).toList();
  }

  Future<void> updateEvent(Event updatedEvent) async {
    await _localStorageService.updateEvent(updatedEvent.toMap());
  }

  Future<void> deleteEvent(int eventId) async {
    await _localStorageService.deleteEvent(eventId);
  }
}
