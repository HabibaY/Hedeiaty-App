// import 'package:flutter/material.dart';
// import '../controllers/gift_controller.dart';
// import '../models/gift.dart';
// import 'create_edit_gift_screen.dart';
// import 'dart:convert'; // For base64 image decoding

// class GiftListScreen extends StatefulWidget {
//   final int eventId;

//   const GiftListScreen({super.key, required this.eventId});

//   @override
//   _GiftListScreenState createState() => _GiftListScreenState();
// }

// class _GiftListScreenState extends State<GiftListScreen> {
//   final GiftController _giftController = GiftController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Gifts for Event"),
//         backgroundColor: Colors.purple,
//       ),
//       body: StreamBuilder<List<Gift>>(
//         stream: _giftController.fetchFirestoreGifts(widget.eventId),
//         builder: (context, snapshot) {
//           // Debug logs for real-time stream
//           print("Snapshot state: ${snapshot.connectionState}");
//           print("Snapshot data: ${snapshot.data}");

//           // Loading state
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           // Error handling
//           if (snapshot.hasError) {
//             return Center(
//               child: Text(
//                 "An error occurred: ${snapshot.error}",
//                 style: const TextStyle(color: Colors.red),
//               ),
//             );
//           }

//           // Empty state
//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text("No gifts added yet."));
//           }

//           // Gift list
//           final gifts = snapshot.data!;
//           return SingleChildScrollView(
//             child: ListView.builder(
//               physics: const BouncingScrollPhysics(), // Smooth scroll
//               shrinkWrap: true, // Allow ListView inside SingleChildScrollView
//               itemCount: gifts.length,
//               itemBuilder: (context, index) {
//                 final gift = gifts[index];
//                 print("Gift object: ID=${gift.id}, Name=${gift.name}"); // Debug

//                 return _buildGiftCard(context, gift);
//               },
//             ),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           await Navigator.push(
//             context,
//             PageRouteBuilder(
//               pageBuilder: (context, animation, secondaryAnimation) =>
//                   CreateEditGiftScreen(eventId: widget.eventId),
//               transitionsBuilder:
//                   (context, animation, secondaryAnimation, child) {
//                 const begin = Offset(1.0, 0.0); // Start from the right
//                 const end = Offset.zero;
//                 const curve = Curves.easeInOut;

//                 final tween = Tween(begin: begin, end: end)
//                     .chain(CurveTween(curve: curve));
//                 final offsetAnimation = animation.drive(tween);

//                 return SlideTransition(
//                   position: offsetAnimation,
//                   child: child,
//                 );
//               },
//             ),
//           );
//           setState(() {}); // Refresh the screen after returning
//         },
//         backgroundColor: Colors.purple,
//         child: const Icon(Icons.add),
//       ),
//     );
//   }

//   Widget _buildGiftCard(BuildContext context, Gift gift) {
//     return Card(
//       color: gift.status == true
//           ? Colors.red[100]
//           : Colors.green[100], // Red for pledged, green for unpledged
//       margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//       child: ListTile(
//         leading: gift.imagePath != null && gift.imagePath!.isNotEmpty
//             ? ClipRRect(
//                 borderRadius: BorderRadius.circular(8.0),
//                 child: Image.memory(
//                   base64Decode(gift.imagePath!),
//                   height: 60,
//                   width: 60,
//                   fit: BoxFit.cover,
//                 ),
//               )
//             : const Icon(Icons.image, color: Colors.grey), // Placeholder icon
//         title: Text(
//           gift.name,
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Colors.purple,
//           ),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text("Category: ${gift.category}, Price: \$${gift.price}"),
//             if (gift.status == true)
//               const Text(
//                 "Status: Pledged",
//                 style: TextStyle(color: Colors.red),
//               ),
//           ],
//         ),
//         trailing: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Edit Button
//             IconButton(
//               icon: const Icon(Icons.edit, color: Colors.purple),
//               onPressed: () async {
//                 await Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => CreateEditGiftScreen(
//                       giftId: gift.id,
//                       eventId: widget.eventId,
//                     ),
//                   ),
//                 );
//                 setState(() {}); // Refresh after editing
//               },
//             ),

//             // Delete Button
//             IconButton(
//               icon: const Icon(Icons.delete, color: Colors.red),
//               onPressed: () async {
//                 await _giftController.deleteGift(gift.id!);
//                 print("Gift deleted successfully: ${gift.name}");
//                 setState(() {}); // Refresh the screen after deletion
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../controllers/gift_controller.dart';
import '../models/gift.dart';
import 'create_edit_gift_screen.dart';
import 'dart:convert'; // For base64 image decoding

class GiftListScreen extends StatefulWidget {
  final int eventId;

  const GiftListScreen({super.key, required this.eventId});

  @override
  _GiftListScreenState createState() => _GiftListScreenState();
}

class _GiftListScreenState extends State<GiftListScreen> {
  final GiftController _giftController = GiftController();
  String _selectedSortOption = "Name"; // Default sorting option

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gifts for Event"),
        backgroundColor: Colors.purple,
        actions: [
          DropdownButton<String>(
            value: _selectedSortOption,
            icon: const Icon(Icons.sort, color: Colors.white),
            dropdownColor: const Color.fromARGB(255, 159, 155, 159),
            underline: Container(),
            items: const [
              DropdownMenuItem(
                value: "Name",
                child: Text("Sort by Name"),
              ),
              DropdownMenuItem(
                value: "Category",
                child: Text("Sort by Category"),
              ),
              DropdownMenuItem(
                value: "Status",
                child: Text("Sort by Status"),
              ),
              DropdownMenuItem(
                value: "Price",
                child: Text("Sort by Price"),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedSortOption = value!;
              });
            },
          ),
        ],
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
          List<Gift> gifts = snapshot.data!;

          // Apply sorting
          if (_selectedSortOption == "Name") {
            gifts.sort((a, b) => a.name.compareTo(b.name));
          } else if (_selectedSortOption == "Category") {
            gifts.sort((a, b) => a.category.compareTo(b.category));
          } else if (_selectedSortOption == "Status") {
            gifts.sort(
                (a, b) => b.status.toString().compareTo(a.status.toString()));
          } else if (_selectedSortOption == "Price") {
            gifts.sort((a, b) => a.price.compareTo(b.price));
          }

          return SingleChildScrollView(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(), // Smooth scroll
              shrinkWrap: true, // Allow ListView inside SingleChildScrollView
              itemCount: gifts.length,
              itemBuilder: (context, index) {
                final gift = gifts[index];
                print("Gift object: ID=${gift.id}, Name=${gift.name}"); // Debug

                return _buildGiftCard(context, gift);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  CreateEditGiftScreen(eventId: widget.eventId),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0); // Start from the right
                const end = Offset.zero;
                const curve = Curves.easeInOut;

                final tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                final offsetAnimation = animation.drive(tween);

                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
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
        leading: gift.imagePath != null && gift.imagePath!.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.memory(
                  base64Decode(gift.imagePath!),
                  height: 60,
                  width: 60,
                  fit: BoxFit.cover,
                ),
              )
            : const Icon(Icons.image, color: Colors.grey), // Placeholder icon
        title: Text(
          gift.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.purple,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Category: ${gift.category}, Price: \$${gift.price}"),
            if (gift.status == true)
              const Text(
                "Status: Pledged",
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
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
                await _giftController.deleteGift(gift.id!);
                print("Gift deleted successfully: ${gift.name}");
                setState(() {}); // Refresh the screen after deletion
              },
            ),
          ],
        ),
      ),
    );
  }
}
