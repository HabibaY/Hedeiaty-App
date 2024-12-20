import 'package:flutter_test/flutter_test.dart'; // For testing
import 'package:mockito/mockito.dart'; // For mocking
import 'package:flutter_application_1/controllers/event_controller.dart'; // EventController
import 'package:flutter_application_1/models/event.dart'; // Event model
import 'package:flutter_application_1/storage/local_storage_service.dart'; // LocalStorageService

class MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  late MockLocalStorageService mockLocalStorageService;
  late EventController eventController;

  setUp(() {
    mockLocalStorageService = MockLocalStorageService();
    eventController = EventController();
  });

  group('EventController Tests', () {
    test('Add event to local storage', () async {
      // Arrange
      final eventData = {
        'name': 'Meeting',
        'date': '2024-12-31',
        'location': 'Office',
        'description': 'Team meeting',
        'category': 'Work',
        'userId': 'user123',
        'isPublished': false,
      };

      when(mockLocalStorageService.insertEvent(eventData))
          .thenAnswer((_) async => 1);

      // Act
      await eventController.addEvent(
        name: 'Meeting',
        date: '2024-12-31',
        location: 'Office',
        description: 'Team meeting',
        category: 'Work',
        userId: 'user123',
        isPublished: false,
      );

      // Assert
      verify(mockLocalStorageService.insertEvent(eventData)).called(1);
    });

    test('Fetch events for a user from local storage', () async {
      // Arrange
      final mockEvents = [
        {
          'id': 1,
          'name': 'Meeting',
          'date': '2024-12-31',
          'location': 'Office',
          'description': 'Team meeting',
          'category': 'Work',
          'isPublished': 0,
          'userId': 'user123',
        }
      ];

      when(mockLocalStorageService.getEventsForUser('user123'))
          .thenAnswer((_) async => mockEvents);

      // Act
      final events = await eventController.getEventsForUser('user123');

      // Assert
      expect(events.length, 1);
      expect(events.first.name, 'Meeting');
    });

    test('Delete unpublished event from local storage', () async {
      // Arrange
      final eventId = 1;
      when(mockLocalStorageService.getEventById(eventId))
          .thenAnswer((_) async => {
                'id': 1,
                'name': 'Meeting',
                'isPublished': 0,
              });
      when(mockLocalStorageService.deleteEvent(eventId))
          .thenAnswer((_) async => 1);

      // Act
      final result = await eventController.deleteEvent(eventId);

      // Assert
      expect(result, true);
      verify(mockLocalStorageService.deleteEvent(eventId)).called(1);
    });
  });
}
