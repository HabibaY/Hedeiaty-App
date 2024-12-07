// import 'package:contacts_service/contacts_service.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import '../widgets/friend_list_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Future<void> _requestContactPermission() async {
  //   // Check if the permission is already granted
  //   if (await Permission.contacts.request().isGranted) {
  //     // Permission is granted; proceed to get contacts.
  //     Iterable<Contact> contacts = await ContactsService.getContacts();
  //     print('Contacts retrieved: ${contacts.length}');
  //     // You can handle the contacts (e.g., display or use them)
  //   } else {
  //     // Handle denied permission
  //     print('Permission denied');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Main Body with Custom Top Section
      body: Column(
        children: [
          // Top section with background color and larger profile picture
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height *
                0.3, // Takes 30% of the height
            decoration: const BoxDecoration(
              color: Color(0xFFE1BEE7), // Light purple color to match the theme
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
                  // Larger Profile Picture
                  const CircleAvatar(
                    backgroundImage: AssetImage('assets/woman1.jpg'),
                    radius: 40, // Increased size of the profile picture
                  ),
                  const SizedBox(height: 20),
                  // Search Bar Section
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search friend',
                        prefixIcon: Icon(Icons.search, color: Colors.purple),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onSubmitted: (value) {
                        // Perform search and navigate to FriendGiftListScreen if found
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
          // Create Your Own Event/List Button
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/createEvent');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple, // Button color to match theme
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
          // Friend List Display
          const Expanded(
            child: Center(
              child: Text(
                'No friends list',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
      // Floating Action Button to Access Contacts
      floatingActionButton: const FloatingActionButton(
        onPressed:
            null, //_requestContactPermission, // Request permission before accessing contacts
        backgroundColor: Colors.purple, // Change FAB color to match the theme
        child: Icon(Icons.add),
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
