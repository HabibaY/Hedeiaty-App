// test/models/event_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/event.dart';

void main() {
  group('Event Model Tests', () {
    test('should create event with valid data', () {
      final event = Event(
          name: 'Birthday Party',
          date: '2024-12-25',
          location: 'Home',
          description: 'My birthday celebration',
          category: 'Birthday',
          isPublished: false,
          userId: 'user123');

      expect(event.name, 'Birthday Party');
      expect(event.date, '2024-12-25');
      expect(event.isPublished, false);
    });

    test('should convert to and from map', () {
      final event = Event(
          id: 1,
          name: 'Birthday Party',
          date: '2024-12-25',
          location: 'Home',
          description: 'My birthday celebration',
          category: 'Birthday',
          eId: 'firebase123',
          isPublished: true,
          userId: 'user123');

      final map = event.toMap();
      final reconstructedEvent = Event.fromMap(map);

      expect(reconstructedEvent.id, event.id);
      expect(reconstructedEvent.name, event.name);
      expect(reconstructedEvent.isPublished, event.isPublished);
    });

    test('should create from Firestore data', () {
      final firestoreData = {
        'name': 'Birthday Party',
        'date': '2024-12-25',
        'location': 'Home',
        'description': 'My birthday celebration',
        'category': 'Birthday'
      };

      final event = Event.fromFirestore(firestoreData, 'docId123', 'user123');

      expect(event.eId, 'docId123');
      expect(event.isPublished, true);
      expect(event.userId, 'user123');
    });
  });
}
