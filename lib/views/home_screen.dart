import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart'; // UserProvider for managing userId

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<UserProvider>(context).userId;
    return Scaffold(
      body: Column(
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
                        prefixIcon: Icon(Icons.search, color: Colors.purple),
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
