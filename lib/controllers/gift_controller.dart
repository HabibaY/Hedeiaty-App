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
    required int eventId,
  }) async {
    final gift = Gift(
      name: name,
      description: description,
      category: category,
      price: price,
      status: status,
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
}
