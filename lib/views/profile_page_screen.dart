import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart'; // Import UserProvider
import '../storage/firebase_auth.dart'; // Import FirebaseAuthService

class ProfilePageScreen extends StatefulWidget {
  const ProfilePageScreen({super.key});

  @override
  State<ProfilePageScreen> createState() => _ProfilePageScreenState();
}

class _ProfilePageScreenState extends State<ProfilePageScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool receiveGiftPledgeNotifications = true;
  String userName = "User Name"; // Default user name

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userId = Provider.of<UserProvider>(context, listen: false).userId;
      if (userId != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          setState(() {
            userName = userDoc['name'] ?? "User Name";
            receiveGiftPledgeNotifications =
                userDoc['notificationsEnabled'] ?? true;
          });
        }
      }
    } catch (e) {
      print("Error loading user data: $e");
    }
  }

  Future<void> _updateNotifications(bool value) async {
    try {
      final userId = Provider.of<UserProvider>(context, listen: false).userId;
      if (userId != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({'notificationsEnabled': value});
        setState(() {
          receiveGiftPledgeNotifications = value;
        });
      }
    } catch (e) {
      final snackBar =
          SnackBar(content: Text('Failed to update notifications: $e'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> _logout() async {
    try {
      await _authService.signOut();
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login', // Replace with your login screen route
        (route) => false,
      );
    } catch (e) {
      final snackBar =
          SnackBar(content: Text('Logout failed: ${e.toString()}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Top section for Profile Picture and Background
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.purple[300],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage('assets/woman1.jpg'),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.purple,
                          ),
                          onPressed: () {
                            // Logic to edit profile picture
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Settings Section
          Padding(
            padding: const EdgeInsets.only(top: 250.0),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person, color: Colors.purple),
                      title: const Text("Edit Personal Information"),
                      onTap: () {
                        // Navigate to edit personal information screen
                      },
                    ),
                    ListTile(
                      leading:
                          const Icon(Icons.notifications, color: Colors.purple),
                      title: const Text("Receive Gift Pledge Notifications"),
                      trailing: Switch(
                        value: receiveGiftPledgeNotifications,
                        onChanged: (bool value) {
                          _updateNotifications(value);
                        },
                        activeColor: Colors.purple,
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.event, color: Colors.purple),
                      title: const Text("My Events"),
                      onTap: () {
                        Navigator.pushNamed(context, '/eventList');
                      },
                    ),
                    ListTile(
                      leading:
                          const Icon(Icons.card_giftcard, color: Colors.purple),
                      title: const Text("My Pledged Gifts"),
                      onTap: () {
                        Navigator.pushNamed(context, '/pledgedGifts');
                      },
                    ),
                    const Spacer(),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text("Logout"),
                      onTap: _logout,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/eventList');
          }
        },
      ),
    );
  }
}
