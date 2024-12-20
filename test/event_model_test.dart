import 'package:flutter_test/flutter_test.dart';
import '../lib/models/event.dart';

void main() {
  group('Event Model Tests', () {
    test('Convert Event to Map', () {
      // Arrange
      Event event = Event(
        id: 1,
        name: 'Meeting',
        date: '2024-12-31',
        location: 'Office',
        description: 'Team meeting',
        category: 'Work',
        isPublished: false,
        userId: 'user123',
      );

      // Act
      Map<String, dynamic> eventMap = event.toMap();

      // Assert
      expect(eventMap['id'], 1);
      expect(eventMap['name'], 'Meeting');
      expect(eventMap['isPublished'], 0);
    });

    test('Create Event from Map', () {
      // Arrange
      Map<String, dynamic> map = {
        'id': 1,
        'name': 'Meeting',
        'date': '2024-12-31',
        'location': 'Office',
        'description': 'Team meeting',
        'category': 'Work',
        'isPublished': 1,
        'userId': 'user123'
      };

      // Act
      Event event = Event.fromMap(map);

      // Assert
      expect(event.name, 'Meeting');
      expect(event.isPublished, true);
    });
  });
}
