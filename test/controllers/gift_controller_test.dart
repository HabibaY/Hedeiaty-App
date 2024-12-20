import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/controllers/gift_controller.dart';
import 'package:flutter_application_1/models/gift.dart';
import 'package:mockito/mockito.dart'; // For mocking
import 'package:flutter_application_1/storage/local_storage_service.dart'; // LocalStorageService

class MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  late MockLocalStorageService mockLocalStorageService;
  late GiftController giftController;

  setUp(() {
    mockLocalStorageService = MockLocalStorageService();
    giftController = GiftController();
  });

  group('GiftController Tests', () {
    test('Add gift to local storage', () async {
      // Arrange
      final giftData = {
        'name': 'Toy Car',
        'description': 'For a child',
        'category': 'Toys',
        'price': 20.0,
        'status': false,
        'dueDate': '2024-12-15',
        'eventId': 1,
      };

      when(mockLocalStorageService.insertGift(giftData))
          .thenAnswer((_) async => 1);

      // Act
      await giftController.addGift(
        name: 'Toy Car',
        description: 'For a child',
        category: 'Toys',
        price: 20.0,
        status: false,
        dueDate: '2024-12-15',
        eventId: 1,
      );

      // Assert
      verify(mockLocalStorageService.insertGift(giftData)).called(1);
    });

    test('Fetch all gifts from local storage', () async {
      // Arrange
      final mockGifts = [
        {
          'id': 1,
          'name': 'Toy Car',
          'description': 'For a child',
          'category': 'Toys',
          'price': 20.0,
          'status': 0,
          'eventId': 1,
        }
      ];

      when(mockLocalStorageService.getGifts())
          .thenAnswer((_) async => mockGifts);

      // Act
      final gifts = await giftController.getGifts();

      // Assert
      expect(gifts.length, 1);
      expect(gifts.first.name, 'Toy Car');
    });
  });
}
