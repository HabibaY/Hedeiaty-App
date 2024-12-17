import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/event.dart';
import '../controllers/event_controller.dart';
import 'create_edit_event_screen.dart';
import 'event_details_screen.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';

class EventListScreen extends StatefulWidget {
  final String userId; // Current logged-in user ID
  const EventListScreen({super.key, required this.userId});

  @override
  _EventListScreenState createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  final EventController _eventController = EventController();
  DateTime _selectedDay = DateTime.now();
  List<Event> _events = [];
  String _sortOption = "Status";
  Map<DateTime, List<Event>> _eventsByDate = {};

  Future<void> _fetchEvents() async {
    final events = await _eventController.getEventsForUser(widget.userId);
    if (events.isEmpty) {
      print('No events available for user $widget.userId.');
    } else {
      print('Fetched ${events.length} events for user $widget.userId.');
    }
    setState(() {
      _events = events;
      _eventsByDate = _groupEventsByDate(events);
    });
  }

  Map<DateTime, List<Event>> _groupEventsByDate(List<Event> events) {
    Map<DateTime, List<Event>> groupedEvents = {};
    for (var event in events) {
      final eventDate = DateTime.parse(event.date);
      final dateKey = DateTime(eventDate.year, eventDate.month, eventDate.day);
      if (groupedEvents[dateKey] == null) {
        groupedEvents[dateKey] = [];
      }
      groupedEvents[dateKey]!.add(event);
    }
    return groupedEvents;
  }

  Future<void> _deleteEvent(int eventId) async {
    bool success = await _eventController.deleteEvent(eventId);

    if (success) {
      // Fetch updated event list after deletion
      _fetchEvents();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Event deleted successfully."),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Show error message if the event is published
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cannot delete published events."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Event> _filterEvents(String status) {
    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);
    final currentMonthEnd = DateTime(now.year, now.month + 1, 0);

    switch (status) {
      case "Past":
        return _events
            .where((e) => DateTime.parse(e.date).isBefore(currentMonthStart))
            .toList();
      case "Current":
        return _events.where((e) {
          final eventDate = DateTime.parse(e.date);
          return (eventDate.isAfter(currentMonthStart) ||
                  eventDate.isAtSameMomentAs(currentMonthStart)) &&
              (eventDate.isBefore(currentMonthEnd) ||
                  eventDate.isAtSameMomentAs(currentMonthEnd));
        }).toList();
      case "Upcoming":
        return _events
            .where((e) => DateTime.parse(e.date).isAfter(currentMonthEnd))
            .toList();
      default:
        return _events;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    final pastEvents = _filterEvents("Past");
    final currentEvents = _filterEvents("Current");
    final upcomingEvents = _filterEvents("Upcoming");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Events"),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload),
            onPressed: () async {
              await _eventController.publishEventsAndGifts(widget.userId);

              _fetchEvents(); // Refresh the event list after publishing
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Unpublished events successfully uploaded!"),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Compressed Calendar Widget
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TableCalendar(
                focusedDay: _selectedDay,
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                calendarFormat: CalendarFormat.twoWeeks,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay; // Update the selected day
                  });
                },
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                calendarStyle: CalendarStyle(
                  selectedDecoration: const BoxDecoration(
                    color: Colors.purple,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: const BoxDecoration(
                    color: Colors.pinkAccent,
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 1,
                  markerDecoration: const BoxDecoration(
                    color: Colors.purple,
                    shape: BoxShape.circle,
                  ),
                  markersAlignment: Alignment.bottomCenter,
                ),
                eventLoader: (day) {
                  final dateKey = DateTime(day.year, day.month, day.day);
                  return _eventsByDate[dateKey] ?? [];
                },
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
            ),
            if (_events.isEmpty)
              const Center(
                child: Text(
                  "No events yet",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else ...[
              // Sort-By Widget
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Sort by:",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    DropdownButton<String>(
                      value: _sortOption,
                      items: ["Name", "Category", "Status"]
                          .map((option) => DropdownMenuItem(
                              value: option, child: Text(option)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _sortOption = value!;
                          _events.sort((a, b) {
                            if (_sortOption == "Name") {
                              return a.name.compareTo(b.name);
                            } else if (_sortOption == "Category") {
                              return a.category.compareTo(b.category);
                            } else if (_sortOption == "Status") {
                              final now = DateTime.now();
                              final aDate = DateTime.parse(a.date);
                              final bDate = DateTime.parse(b.date);

                              // Categorize events into Past, Current, and Upcoming
                              bool aIsPast = aDate.isBefore(now);
                              bool bIsPast = bDate.isBefore(now);

                              bool aIsCurrent = aDate.isAfter(
                                      now.subtract(const Duration(days: 1))) &&
                                  aDate.isBefore(
                                      now.add(const Duration(days: 1)));
                              bool bIsCurrent = bDate.isAfter(
                                      now.subtract(const Duration(days: 1))) &&
                                  bDate.isBefore(
                                      now.add(const Duration(days: 1)));

                              // Sorting logic for Status
                              if (aIsPast && bIsPast ||
                                  aIsCurrent && bIsCurrent ||
                                  !aIsPast &&
                                      !bIsPast &&
                                      !aIsCurrent &&
                                      !bIsCurrent) {
                                return aDate.compareTo(
                                    bDate); // Sort by ascending date within the same category
                              } else if (aIsPast) {
                                return -1; // Past events first
                              } else if (bIsPast) {
                                return 1; // Past events first
                              } else if (aIsCurrent) {
                                return -1; // Current events second
                              } else if (bIsCurrent) {
                                return 1; // Current events second
                              }
                            }
                            return 0; // Default case
                          });
                        });
                      },
                    ),
                  ],
                ),
              ),
              // Events categorized
              _buildEventList("Past Events", pastEvents),
              _buildEventList("Current Events", currentEvents),
              _buildEventList("Upcoming Events", upcomingEvents),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateEditEventScreen(
                initialDate: _selectedDay, // Pass the selected day
                userId: widget.userId,
              ),
            ),
          ).then((_) => _fetchEvents()); // Refresh events after returning
        },
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Highlight "Events"
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
              if (ModalRoute.of(context)?.settings.name != '/home') {
                Navigator.pushNamed(context, '/home');
              }
              break;
            case 1:
              if (ModalRoute.of(context)?.settings.name != '/eventList') {
                Navigator.pushNamed(context, '/eventList');
              }
              break;
            case 2:
              if (ModalRoute.of(context)?.settings.name != '/profile') {
                Navigator.pushNamed(context, '/profile');
              }
              break;
          }
        },
      ),
    );
  }

  Widget _buildEventList(String title, List<Event> events) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...events.map((event) => Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.purple[50],
                child: ListTile(
                  title: Text(event.name),
                  subtitle: Text("Date: ${event.date}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.purple),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateEditEventScreen(
                                eventId: event.id,
                                userId: widget.userId,
                              ),
                            ),
                          ).then((_) => _fetchEvents());
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.visibility, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EventDetailsScreen(
                                  eventId: event.eId ??
                                      event.id
                                          .toString(), // Use Firestore `eId` or local `id`

                                  userId: event.userId, // Pass user ID
                                ),
                              ));
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteEvent(event.id!),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'View Gift List') {
                            final eventProvider = Provider.of<EventProvider>(
                                context,
                                listen: false);
                            eventProvider.setEventId(event.id!);
                            Navigator.pushNamed(context, '/giftList');
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return {'View Gift List'}
                              .map((String choice) => PopupMenuItem(
                                  value: choice, child: Text(choice)))
                              .toList();
                        },
                        icon: const Icon(Icons.more_vert),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
