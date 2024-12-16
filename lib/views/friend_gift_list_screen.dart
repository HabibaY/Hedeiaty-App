import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class FriendGiftListScreen extends StatefulWidget {
  const FriendGiftListScreen({super.key});

  @override
  _FriendGiftListScreenState createState() => _FriendGiftListScreenState();
}

class _FriendGiftListScreenState extends State<FriendGiftListScreen> {
  Future<List<Map<String, dynamic>>> _fetchGifts(
      String friendId, String eventId) async {
    try {
      final giftsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(friendId)
          .collection('events')
          .doc(eventId)
          .collection('gifts')
          .where('status', isEqualTo: false)
          .get();

      return giftsSnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc.data()['name'] ?? 'No Name',
                'category': doc.data()['category'] ?? 'No Category',
                'price': doc.data()['price'] ?? 'N/A',
                'status': doc.data()['status'] ?? false,
                'dueDate': doc.data()['dueDate'] ?? 'No Due Date',
              })
          .toList();
    } catch (e) {
      print("Error fetching gifts: $e");
      return [];
    }
  }

  Future<void> _pledgeGift(String userId, String friendId, String eventId,
      Map<String, dynamic> gift) async {
    try {
      final giftId = gift['id'];

      // 1. Optimistically update the local UI
      setState(() {
        gift['status'] = true;
      });

      // 2. Update the gift status in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(friendId)
          .collection('events')
          .doc(eventId)
          .collection('gifts')
          .doc(giftId)
          .update({'status': true});

      // 3. Add the gift to the current user's "pledged_gifts" subcollection
      final userPledgedGiftsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('pledged_gifts');

      await userPledgedGiftsRef.doc('pledged_gifts_doc').set({
        'gIds': FieldValue.arrayUnion([giftId]),
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error pledging gift: $e");

      // Revert local changes in case of an error
      setState(() {
        gift['status'] = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final friendId = args['friendId'];
    final eventId = args['eventId'];
    final userId = Provider.of<UserProvider>(context, listen: false).userId;

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
                            const SizedBox(height: 4),
                            Text(
                              "Price: \$${gift['price']}",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Due Date: ${gift['dueDate']}",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: gift['status']
                              ? null
                              : () async {
                                  if (userId != null) {
                                    await _pledgeGift(
                                        userId, friendId, eventId, gift);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "User ID is null. Please log in again."),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                gift['status'] ? Colors.grey : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            gift['status'] ? "Pledged" : "Pledge",
                            style: TextStyle(
                              color:
                                  gift['status'] ? Colors.grey : Colors.purple,
                            ),
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
