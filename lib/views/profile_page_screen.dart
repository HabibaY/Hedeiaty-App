import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart'; // Import UserProvider
import '../storage/firebase_auth.dart'; // Import FirebaseAuthService
import '../controllers/user_controller.dart'; // Import UserController

class ProfilePageScreen extends StatefulWidget {
  const ProfilePageScreen({super.key});

  @override
  State<ProfilePageScreen> createState() => _ProfilePageScreenState();
}

class _ProfilePageScreenState extends State<ProfilePageScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool receiveGiftPledgeNotifications = true;
  String userName = "User Name"; // Default user name
  String userEmail = ""; // Default user email
  String userPhoneNumber = ""; // Default phone number
  String profileImagePath =
      'assets/default_avatar.png'; // Default profile image

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
            userEmail = userDoc['email'] ?? ""; // Fetch user email
            userPhoneNumber =
                userDoc['phoneNumber'] ?? ""; // Fetch phone number
            profileImagePath =
                userDoc['profileImagePath'] ?? 'assets/default_avatar.png';
            receiveGiftPledgeNotifications =
                userDoc['notificationsEnabled'] ?? true;
          });
        }
      }
    } catch (e) {
      print("Error loading user data: $e");
    }
  }

  Future<void> _editPersonalInformation() async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    if (userId == null) return;

    final TextEditingController nameController =
        TextEditingController(text: userName);
    final TextEditingController emailController =
        TextEditingController(text: userEmail);
    final TextEditingController phoneController =
        TextEditingController(text: userPhoneNumber);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Personal Information"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Phone Number"),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final updatedName = nameController.text.trim();
                final updatedEmail = emailController.text.trim();
                final updatedPhone = phoneController.text.trim();

                try {
                  // Use UserController instance
                  final userController = UserController();

                  // Update current user's information
                  await userController.updateUserInformation(
                    uid: userId,
                    name: updatedName.isNotEmpty ? updatedName : null,
                    email: updatedEmail.isNotEmpty ? updatedEmail : null,
                    phoneNumber: updatedPhone.isNotEmpty ? updatedPhone : null,
                  );

                  // Propagate updates to friends' subcollections
                  if (updatedName.isNotEmpty || updatedPhone.isNotEmpty) {
                    await userController.propagateFriendUpdates(
                      userId: userId,
                      updatedName:
                          updatedName.isNotEmpty ? updatedName : userName,
                      updatedPhoneNumber: updatedPhone.isNotEmpty
                          ? updatedPhone
                          : userPhoneNumber,
                    );
                  }

                  // Update the UI
                  setState(() {
                    userName = updatedName.isNotEmpty ? updatedName : userName;
                    userEmail =
                        updatedEmail.isNotEmpty ? updatedEmail : userEmail;
                    userPhoneNumber = updatedPhone.isNotEmpty
                        ? updatedPhone
                        : userPhoneNumber;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Personal information updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update information: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }

                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editProfilePicture() async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    if (userId == null) return;

    // List of available images
    List<String> images = [
      'assets/profile/P1.PNG',
      'assets/profile/P2.PNG',
      'assets/profile/P3.png',
      'assets/profile/P4.png',
      'assets/profile/P5.png',
      'assets/profile/P6.png',
      'assets/profile/P7.png',
      'assets/profile/P8.png',
      'assets/profile/P9.PNG',
    ];

    // Show the modal bottom sheet with image options
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select a Profile Picture',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: images.map((image) {
                  return GestureDetector(
                    onTap: () async {
                      // Update Firestore
                      await _updateProfilePicture(userId, image);
                      Navigator.pop(context); // Close the modal
                    },
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage(image),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateProfilePicture(String userId, String imagePath) async {
    try {
      // Update Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'profileImagePath': imagePath});

      // Update UI
      setState(() {
        profileImagePath = imagePath;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile picture updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile picture: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage(profileImagePath),
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
                          onPressed: _editProfilePicture,
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
                      onTap: _editPersonalInformation,
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
