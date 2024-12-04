// import '../models/gift.dart';
// import '../services/local_storage_service.dart';

// class GiftController {
//   final LocalStorageService _localStorageService = LocalStorageService();

//   // Add a new gift
//   Future<void> addGift(String name, String description, String category,
//       double price, String status, int eventId) async {
//     Gift gift = Gift(
//       name: name,
//       description: description,
//       category: category,
//       price: price,
//       status: status,
//       eventId: eventId,
//     );
//     await _localStorageService.insertGift(gift.toMap());
//   }

//   // Retrieve all gifts
//   Future<List<Gift>> getGifts() async {
//     List<Map<String, dynamic>> giftsMap = await _localStorageService.getGifts();
//     return giftsMap.map((map) => Gift.fromMap(map)).toList();
//   }

//   // Retrieve gifts for a specific event
//   Future<List<Gift>> getGiftsForEvent(int eventId) async {
//     List<Map<String, dynamic>> giftsMap =
//         await _localStorageService.getGiftsForEvent(eventId);
//     return giftsMap.map((map) => Gift.fromMap(map)).toList();
//   }

//   // Update an existing gift
//   Future<void> updateGift(Gift updatedGift) async {
//     await _localStorageService.updateGift(updatedGift.toMap());
//   }

//   // Delete a gift
//   Future<void> deleteGift(int giftId) async {
//     await _localStorageService.deleteGift(giftId);
//   }
// }
