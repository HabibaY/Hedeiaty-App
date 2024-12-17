import 'package:flutter/material.dart';
import '../controllers/gift_controller.dart';
import '../models/gift.dart';
import 'create_edit_gift_screen.dart';

class GiftListScreen extends StatefulWidget {
  final int eventId;

  const GiftListScreen({super.key, required this.eventId});

  @override
  _GiftListScreenState createState() => _GiftListScreenState();
}

class _GiftListScreenState extends State<GiftListScreen> {
  final GiftController _giftController = GiftController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gifts for Event"),
        backgroundColor: Colors.purple,
      ),
      body: StreamBuilder<List<Gift>>(
        stream: _giftController.fetchFirestoreGifts(widget.eventId),
        builder: (context, snapshot) {
          // Debug logs for real-time stream
          print("Snapshot state: ${snapshot.connectionState}");
          print("Snapshot data: ${snapshot.data}");

          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error handling
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "An error occurred: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          // Empty state
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No gifts added yet."));
          }

          // Gift list
          final gifts = snapshot.data!;
          return ListView.builder(
            itemCount: gifts.length,
            itemBuilder: (context, index) {
              final gift = gifts[index];
              print("Gift: ${gift.name}, Status: ${gift.status}"); // Debug
              return _buildGiftCard(context, gift);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CreateEditGiftScreen(eventId: widget.eventId),
            ),
          );
          setState(() {}); // Refresh the screen after returning
        },
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGiftCard(BuildContext context, Gift gift) {
    return Card(
      color: gift.status == true
          ? Colors.red[100]
          : Colors.green[100], // Red for pledged, green for unpledged
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        title: Text(
          gift.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.purple,
          ),
        ),
        subtitle: Text("Category: ${gift.category}, Price: \$${gift.price}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Edit Button
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.purple),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateEditGiftScreen(
                      giftId: gift.id,
                      eventId: widget.eventId,
                    ),
                  ),
                );
                setState(() {}); // Refresh after editing
              },
            ),

            // Delete Button
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                if (gift.gId != null) {
                  // Confirm valid Firestore ID before deleting
                  await _giftController.deleteGift(gift.id!);
                  print("Gift deleted successfully: ${gift.name}");
                } else {
                  print("Error: Invalid gift ID for deletion.");
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
