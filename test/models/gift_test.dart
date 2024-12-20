// test/models/gift_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/gift.dart';

void main() {
  group('Gift Model Tests', () {
    test('should create gift with valid data', () {
      final gift = Gift(
          name: 'iPhone',
          description: 'Latest iPhone model',
          category: 'Electronics',
          price: 999.99,
          status: false,
          dueDate: '2024-12-25',
          eventId: 1);

      expect(gift.name, 'iPhone');
      expect(gift.price, 999.99);
      expect(gift.status, false);
    });

    test('should convert to and from map', () {
      final gift = Gift(
          id: 1,
          name: 'iPhone',
          description: 'Latest iPhone model',
          category: 'Electronics',
          price: 999.99,
          status: false,
          dueDate: '2024-12-25',
          imagePath: '/path/to/image.jpg',
          gId: 'firebase123',
          eventId: 1);

      final map = gift.toMap();
      final reconstructedGift = Gift.fromMap(map);

      expect(reconstructedGift.id, gift.id);
      expect(reconstructedGift.name, gift.name);
      expect(reconstructedGift.price, gift.price);
      expect(reconstructedGift.status, gift.status);
    });

    test('should handle null values properly', () {
      final gift = Gift(
          name: 'iPhone',
          description: 'Latest iPhone model',
          category: 'Electronics',
          price: 999.99,
          status: false,
          dueDate: '2024-12-25',
          eventId: 1);

      final map = gift.toMap();
      final reconstructedGift = Gift.fromMap(map);

      expect(reconstructedGift.id, isNull);
      expect(reconstructedGift.gId, isNull);
      expect(reconstructedGift.imagePath, isNull);
    });
  });
}
