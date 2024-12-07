import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'create_edit_event_screen.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  _EventListScreenState createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Events"),
        backgroundColor: Colors.purple, // Retain purple color theme
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _selectedDay,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            calendarFormat: CalendarFormat.month,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
              });
            },
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            calendarStyle: const CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Colors.purple, // Purple theme for selected day
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.pinkAccent, // Pink accent for today
                shape: BoxShape.circle,
              ),
              weekendTextStyle: TextStyle(
                  color: Colors.pinkAccent), // Pinkish theme for weekends
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false, // Hide the format button
              titleCentered: true,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Upcoming Events",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                buildEventCard(context, "Birthday Party", "2024-12-10"),
                buildEventCard(context, "Wedding", "2024-11-30"),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        selectedItemColor: Colors.purple,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/home');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/profile');
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CreateEditEventScreen(initialDate: _selectedDay),
            ),
          );
        },
        backgroundColor: Colors.purple, // Purple theme for floating button
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildEventCard(
      BuildContext context, String eventName, String eventDate) {
    return Card(
      color: Colors.purple[50], // Light purple background for cards
      child: ListTile(
        title: Text(eventName),
        subtitle: Text("Date: $eventDate"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.purple),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateEditEventScreen(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                // Delete functionality to be implemented later
              },
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'View Gift List') {
                  Navigator.pushNamed(context, '/giftList');
                }
              },
              itemBuilder: (BuildContext context) {
                return {'View Gift List'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
              icon: const Icon(Icons.more_vert), // Three-dot icon
            ),
          ],
        ),
      ),
    );
  }
}
