import '../models/gift.dart';
import '../storage/local_storage_service.dart';

class GiftController {
  final LocalStorageService _localStorageService = LocalStorageService();

  Future<void> addGift({
    required String name,
    required String description,
    required String category,
    required double price,
    required bool status,
    String? gId, // Optional Firestore ID
    required int eventId,
  }) async {
    final gift = Gift(
      name: name,
      description: description,
      category: category,
      price: price,
      status: status,
      gId: gId, // Pass Firestore ID or null
      eventId: eventId,
    );
    await _localStorageService.insertGift(gift.toMap());
  }

  Future<List<Gift>> getGifts() async {
    final giftsMap = await _localStorageService.getGifts();
    return giftsMap.map((map) => Gift.fromMap(map)).toList();
  }

  Future<List<Gift>> getGiftsForEvent(int eventId) async {
    final giftsMap = await _localStorageService.getGiftsForEvent(eventId);
    return giftsMap.map((map) => Gift.fromMap(map)).toList();
  }

  Future<Gift?> getGiftById(int giftId) async {
    final giftsMap = await _localStorageService.getGiftById(giftId);
    if (giftsMap != null) {
      return Gift.fromMap(giftsMap);
    }
    return null;
  }

  Future<void> updateGift(Gift updatedGift) async {
    await _localStorageService.updateGift(updatedGift.toMap());
  }

  Future<void> deleteGift(int giftId) async {
    await _localStorageService.deleteGift(giftId);
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
        gId: gId, // Update Firestore ID
        eventId: gift.eventId,
      );
      await updateGift(updatedGift);
    }
  }
}
