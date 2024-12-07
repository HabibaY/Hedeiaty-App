import 'package:flutter/material.dart';

class ProfilePageScreen extends StatefulWidget {
  const ProfilePageScreen({super.key});

  @override
  State<ProfilePageScreen> createState() => _ProfilePageScreenState();
}

class _ProfilePageScreenState extends State<ProfilePageScreen> {
  bool receiveGiftPledgeNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Top section for Profile Picture and Background
          Container(
            height: MediaQuery.of(context).size.height *
                0.35, // Takes 35% of the screen height
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.purple[300], // Purple theme background color
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
                      backgroundImage: AssetImage(
                          'assets/woman1.jpg'), // Replace with your image asset
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
                const Text(
                  'User Name', // Replace with user's name
                  style: TextStyle(
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
                          setState(() {
                            receiveGiftPledgeNotifications = value;
                          });
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
                      onTap: () {
                        // Add logout logic
                      },
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
        currentIndex: 2, // Current page is Profile (index 2)
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/eventList');
          } else if (index == 2) {
            // Do nothing as we are already on the profile screen
          }
        },
      ),
    );
  }
}
