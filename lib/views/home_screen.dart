import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/user_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _friendsList = [];

  @override
  void initState() {
    super.initState();
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    if (userId != null) {
      _fetchFriendsList(userId);
    }
  }

  Future<void> _addFriend() async {
    TextEditingController phoneNumberController = TextEditingController();
    final userId = Provider.of<UserProvider>(context, listen: false).userId;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Friend"),
          content: TextField(
            controller: phoneNumberController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(hintText: "Enter phone number"),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String phoneNumber = phoneNumberController.text.trim();
                if (phoneNumber.isEmpty) {
                  Navigator.of(context).pop();
                  return;
                }

                final friendSnapshot = await _firestore
                    .collection('users')
                    .where('phoneNumber', isEqualTo: phoneNumber)
                    .get();

                if (friendSnapshot.docs.isNotEmpty) {
                  final friendData = friendSnapshot.docs.first.data();
                  final friendId = friendSnapshot.docs.first.id;

                  // Get current user data
                  final currentUserSnapshot =
                      await _firestore.collection('users').doc(userId).get();
                  final currentUserData = currentUserSnapshot.data();

                  if (currentUserData == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Current user not found")),
                    );
                    Navigator.of(context).pop();
                    return;
                  }

                  // Add friend to current user's friends collection
                  await _firestore
                      .collection('users')
                      .doc(userId)
                      .collection('friends')
                      .doc(friendId)
                      .set({
                    'name': friendData['name'],
                    'phoneNumber': phoneNumber,
                  });

                  // Add current user to the friend's friends collection
                  await _firestore
                      .collection('users')
                      .doc(friendId)
                      .collection('friends')
                      .doc(userId)
                      .set({
                    'name': currentUserData['name'],
                    'phoneNumber': currentUserData['phoneNumber'],
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Added successfully"),
                      backgroundColor: Colors.green,
                    ),
                  );

                  _fetchFriendsList(userId); // Update the friends list
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Invalid phone number"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }

                Navigator.of(context).pop();
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchFriendsList(String userId) async {
    final friendsSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('friends')
        .get();

    List<Map<String, dynamic>> friendsData = [];
    for (var doc in friendsSnapshot.docs) {
      final friendData = doc.data();
      final friendId = doc.id;
      final friendEventsSnapshot = await _firestore
          .collection('users')
          .doc(friendId)
          .collection('events')
          .get();
      friendsData.add({
        'id': friendId,
        'name': friendData['name'],
        'phoneNumber': friendData['phoneNumber'],
        'eventCount': friendEventsSnapshot.size,
      });
    }

    setState(() {
      _friendsList = friendsData;
    });
  }

  Future<void> _showEventDetailsPopup(
      BuildContext context, String friendId) async {
    final eventsSnapshot = await _firestore
        .collection('users')
        .doc(friendId)
        .collection('events')
        .get();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Event Details"),
          content: eventsSnapshot.docs.isEmpty
              ? const Text("No events available")
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: eventsSnapshot.docs.map((eventDoc) {
                    final eventData = eventDoc.data();
                    final eventId = eventDoc.id; // Capture eventId
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              eventData['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text("Date: ${eventData['date']}"),
                            Text("Location: ${eventData['location']}"),
                            Text("Description: ${eventData['description']}"),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Close popup
                                Navigator.pushNamed(
                                  context,
                                  '/friendGiftList',
                                  arguments: {
                                    'friendId': friendId,
                                    'eventId': eventId,
                                  },
                                );
                              },
                              child: const Text(
                                "Show Gifts",
                                style: TextStyle(color: Colors.purple),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: Colors.purple,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.3,
                decoration: const BoxDecoration(
                  color: Color(0xFFE1BEE7),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        backgroundImage: AssetImage('assets/woman1.jpg'),
                        radius: 40,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Search friend',
                            prefixIcon:
                                Icon(Icons.search, color: Colors.purple),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              Navigator.pushNamed(context, '/friendGiftList');
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/eventList');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Create Your Own Event/List",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                  child: _friendsList.isEmpty
                      ? const Center(
                          child: Text(
                            'No friends list',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _friendsList.length,
                          itemBuilder: (context, index) {
                            final friend = _friendsList[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CircleAvatar(
                                      radius: 30,
                                      backgroundImage:
                                          AssetImage('assets/woman1.jpg'),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          friend['name'],
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Upcoming Events: ${friend['eventCount']}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(16),
                                        bottomRight: Radius.circular(16),
                                      ),
                                    ),
                                    child: TextButton(
                                      onPressed: () {
                                        _showEventDetailsPopup(
                                            context, friend['id']);
                                      },
                                      child: const Text(
                                        'View Details',
                                        style: TextStyle(color: Colors.purple),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        )),
            ],
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: GestureDetector(
              onTap: _addFriend,
              child: Container(
                height: 60,
                width: 60,
                decoration: const BoxDecoration(
                  color: Colors.purple,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_add,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Events'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/eventList');
              break;
            case 2:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }
}
