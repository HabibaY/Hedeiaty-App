import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendGiftListScreen extends StatelessWidget {
  const FriendGiftListScreen({super.key});

  Future<List<Map<String, dynamic>>> _fetchGifts(
      String friendId, String eventId) async {
    try {
      final giftsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(friendId)
          .collection('events')
          .doc(eventId)
          .collection('gifts')
          .get();

      return giftsSnapshot.docs
          .map((doc) => {
                'name': doc.data()['name'] ?? 'No Name',
                'category': doc.data()['category'] ?? 'No Category',
                'price': doc.data()['price'] ?? 'N/A',
              })
          .toList();
    } catch (e) {
      print("Error fetching gifts: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final friendId = args['friendId'];
    final eventId = args['eventId'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Friend's Gift List"),
        backgroundColor: Colors.purple,
      ),
      body: Container(
        color: const Color(0xFFF3E5F5), // Light purple background
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchGifts(friendId, eventId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(
                child: Text(
                  "Failed to load gifts",
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  "No gifts available",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              );
            } else {
              final gifts = snapshot.data!;
              return ListView.builder(
                itemCount: gifts.length,
                itemBuilder: (context, index) {
                  final gift = gifts[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.purple, Colors.deepPurpleAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        title: Text(
                          gift['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Category: ${gift['category']}",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(
                                height: 4), // Add spacing between lines
                            Text(
                              "Price: \$${gift['price']}",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            // Pledge Logic
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            "Pledge",
                            style: TextStyle(color: Colors.purple),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
