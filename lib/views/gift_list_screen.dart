import 'package:flutter/material.dart';
import '../controllers/gift_controller.dart';
import '../models/gift.dart';
import 'create_edit_gift_screen.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/event_provider.dart';

class GiftListScreen extends StatefulWidget {
  final int eventId; // Associated Event ID

  const GiftListScreen({super.key, required this.eventId});

  @override
  _GiftListScreenState createState() => _GiftListScreenState();
}

class _GiftListScreenState extends State<GiftListScreen> {
  final GiftController _giftController = GiftController();
  List<Gift> _gifts = [];
  late Stream<QuerySnapshot> _giftsStream;
  String? firestoreEventId; // Holds the Firestore document ID (eId)
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchGifts();
    _fetchEventId();

    // Initialize Firestore stream to listen for changes
    _giftsStream = FirebaseFirestore.instance
        .collectionGroup('gifts') // Collection Group to find gifts across users
        .where('eventId',
            isEqualTo: widget.eventId) // Filter for matching eventId
        .snapshots();
  }

  Future<void> _fetchEventId() async {
    try {
      final querySnapshot = await _firestore
          .collection('events') // Main collection where events exist
          .where('id', isEqualTo: widget.eventId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          firestoreEventId = querySnapshot.docs.first.id; // Fetch eId
        });
      } else {
        print("Event with local ID ${widget.eventId} not found.");
      }
    } catch (e) {
      print("Error fetching eId: $e");
    }
  }

  /// Fetch gifts locally from GiftController
  Future<void> _fetchGifts() async {
    final gifts = await _giftController.getGiftsForEvent(widget.eventId);
    setState(() {
      _gifts = gifts;
    });
  }

  Future<void> _deleteGift(int giftId) async {
    await _giftController.deleteGift(giftId);
    _fetchGifts();
  }

  @override
  Widget build(BuildContext context) {
    final eventId = Provider.of<EventProvider>(context).eventId;

    if (eventId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Gifts for Event")),
        body: const Center(child: Text("No event selected.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gifts for Event"),
        backgroundColor: Colors.purple,
      ),
      body: _gifts.isEmpty
          ? const Center(
              child: Text(
                "No gifts added yet.",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: _giftsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      "Error loading gifts.",
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }

                // Update local gifts with Firestore changes
                final firestoreGifts = snapshot.data?.docs ?? [];
                for (var giftDoc in firestoreGifts) {
                  final updatedGift = giftDoc.data() as Map<String, dynamic>;
                  final localGiftIndex = _gifts
                      .indexWhere((gift) => gift.id.toString() == giftDoc.id);

                  if (localGiftIndex != -1) {
                    setState(() {
                      _gifts[localGiftIndex].status = updatedGift['status'];
                    });
                  }
                }

                return ListView.builder(
                  itemCount: _gifts.length,
                  itemBuilder: (context, index) {
                    final gift = _gifts[index];
                    return _buildGiftCard(context, gift);
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateEditGiftScreen(
                eventId: widget.eventId,
              ),
            ),
          ).then((_) => _fetchGifts());
        },
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGiftCard(BuildContext context, Gift gift) {
    return Card(
      color: gift.status
          ? Colors.red[100]
          : Colors.green[100], // Status-based color
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gift.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Category: ${gift.category}, Price: \$${gift.price}",
                    style: const TextStyle(color: Colors.black),
                  ),
                  Text(
                    "Status: ${gift.status ? "Pledged" : "Available"}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.purple),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateEditGiftScreen(
                      giftId: gift.id,
                      eventId: widget.eventId,
                    ),
                  ),
                ).then((_) => _fetchGifts());
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteGift(gift.id!),
            ),
          ],
        ),
      ),
    );
  }
}
