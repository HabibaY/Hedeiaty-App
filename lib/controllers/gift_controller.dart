import '../models/gift.dart';
import '../services/local_storage_service.dart';

class GiftController {
  final LocalStorageService _localStorageService = LocalStorageService();

  Future<void> addGift(String name, String description, String category,
      double price, bool status, int eventId) async {
    Gift gift = Gift(
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
    List<Map<String, dynamic>> giftsMap = await _localStorageService.getGifts();
    return giftsMap.map((map) => Gift.fromMap(map)).toList();
  }

  Future<List<Gift>> getGiftsForEvent(int eventId) async {
    List<Map<String, dynamic>> giftsMap =
        await _localStorageService.getGiftsForEvent(eventId);
    return giftsMap.map((map) => Gift.fromMap(map)).toList();
  }

  Future<void> updateGift(Gift updatedGift) async {
    await _localStorageService.updateGift(updatedGift.toMap());
  }

  Future<void> deleteGift(int giftId) async {
    await _localStorageService.deleteGift(giftId);
  }
}
