import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PledgedGiftsScreen extends StatefulWidget {
  final String userId;

  const PledgedGiftsScreen({super.key, required this.userId});

  @override
  _PledgedGiftsScreenState createState() => _PledgedGiftsScreenState();
}

class _PledgedGiftsScreenState extends State<PledgedGiftsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> pledgedGifts = [];
  Map<String, bool> cancelPledgeStatus = {}; // Track the toggle button state

  @override
  void initState() {
    super.initState();
    _fetchPledgedGifts();
  }

  Future<void> _fetchPledgedGifts() async {
    try {
      // Fetch pledged gift IDs
      final pledgedDoc = await _firestore
          .collection('users')
          .doc(widget.userId)
          .collection('pledged_gifts')
          .doc('pledged_gifts_doc')
          .get();

      if (pledgedDoc.exists) {
        List<String> pledgedGiftIds =
            List<String>.from(pledgedDoc.data()?['gIds'] ?? []);

        List<Map<String, dynamic>> fetchedGifts = [];
        Map<String, String> userNameCache = {}; // Cache for user names

        // Iterate over all users -> events -> gifts
        final usersSnapshot = await _firestore.collection('users').get();

        for (var userDoc in usersSnapshot.docs) {
          final userId = userDoc.id;

          // Step 3: Fetch friend's name (only once per user ID)
          final friendName = userNameCache.putIfAbsent(
            userId,
            () => userDoc.data()['name'] ?? 'Unknown Friend',
          );
          final eventsSnapshot = await _firestore
              .collection('users')
              .doc(userDoc.id)
              .collection('events')
              .get();

          for (var eventDoc in eventsSnapshot.docs) {
            final giftsSnapshot = await _firestore
                .collection('users')
                .doc(userDoc.id)
                .collection('events')
                .doc(eventDoc.id)
                .collection('gifts')
                .get();

            for (var giftDoc in giftsSnapshot.docs) {
              if (pledgedGiftIds.contains(giftDoc.id)) {
                final giftData = giftDoc.data();
                fetchedGifts.add({
                  'id': giftDoc.id,
                  'name': giftData['name'] ?? 'No Name',
                  'category': giftData['category'] ?? 'No Category',
                  'price': giftData['price'] ?? 'N/A',
                  'dueDate': giftData['dueDate'] ?? '',
                  'status': giftData['status'] ?? false,
                  'reference': giftDoc.reference, // For updates
                  'friendName': friendName, // Add fetched friend's name here
                });

                cancelPledgeStatus[giftDoc.id] = false; // Initially off
              }
            }
          }
        }

        setState(() {
          pledgedGifts = fetchedGifts;
        });
      } else {
        print('No pledged_gifts_doc found for userId: ${widget.userId}');
      }
    } catch (e) {
      print('Error fetching pledged gifts: $e');
    }
  }

  Future<void> _cancelPledge(String giftId, DocumentReference reference) async {
    try {
      // Remove gift ID from the pledged_gifts document
      await _firestore
          .collection('users')
          .doc(widget.userId)
          .collection('pledged_gifts')
          .doc('pledged_gifts_doc')
          .update({
        'gIds': FieldValue.arrayRemove([giftId]),
      });

      // Set the gift status to "available" (false)
      await reference.update({'status': false});

      // Refresh the pledged list
      _fetchPledgedGifts();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pledge canceled successfully."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error canceling pledge: $e');
    }
  }

  Widget _buildPledgedGiftTile(Map<String, dynamic> gift) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 3,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 4.0,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Gift details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gift['name'],
                    style: const TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Category: ${gift['category']}",
                    style: const TextStyle(color: Colors.black54),
                  ),
                  Text(
                    "Price: \$${gift['price']}",
                    style: const TextStyle(color: Colors.black54),
                  ),
                  Text(
                    "Due Date: ${gift['dueDate']}",
                    style: const TextStyle(color: Colors.black54),
                  ),
                  Text(
                    // Add Friend's Name Here
                    "To: ${gift['friendName']}",
                    style: const TextStyle(
                        color: Colors.deepPurpleAccent,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            // Cancel Pledge Toggle
            Column(
              children: [
                const Text(
                  "Cancel Pledge",
                  style: TextStyle(
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
                  value: cancelPledgeStatus[gift['id']] ?? false,
                  activeColor: Colors.redAccent,
                  onChanged: (bool value) {
                    final dueDate =
                        gift['dueDate']; // Firestore due date (string)
                    final parsedDueDate =
                        DateTime.tryParse(dueDate); // Parse to DateTime

                    if (parsedDueDate != null) {
                      // Check today's date against (dueDate - 2 days)
                      final twoDaysBeforeDueDate =
                          parsedDueDate.subtract(const Duration(days: 2));
                      final today = DateTime.now();

                      if (today.isAfter(twoDaysBeforeDueDate) ||
                          today.isAtSameMomentAs(twoDaysBeforeDueDate)) {
                        // Show error and prevent cancellation
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Cannot cancel pledge, must be 2 days before the due date (${dueDate}).",
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return; // Exit early
                      }
                    }

                    setState(() {
                      cancelPledgeStatus[gift['id']] = value;
                    });

                    if (value) {
                      _cancelPledge(gift['id'], gift['reference']);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Pledged Gifts"),
        backgroundColor: Colors.purple,
      ),
      body: pledgedGifts.isEmpty
          ? const Center(
              child: Text(
                "No pledged gifts available.",
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: pledgedGifts.length,
              itemBuilder: (context, index) {
                return _buildPledgedGiftTile(pledgedGifts[index]);
              },
            ),
    );
  }
}
