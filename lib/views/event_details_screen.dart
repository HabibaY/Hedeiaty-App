import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';
import '../storage/local_storage_service.dart'; // Local storage service for fetching unpublished events

class EventDetailsScreen extends StatefulWidget {
  final String? eventId; // Firestore event ID may be null
  final String userId; // User ID to fetch the event
  const EventDetailsScreen(
      {super.key, required this.eventId, required this.userId});

  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  Event? _event; // Store the fetched event details
  bool _isLoading = true; // Show loading spinner initially
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalStorageService _localStorageService = LocalStorageService();

  @override
  void initState() {
    super.initState();
    _fetchEventDetails();
  }

  Future<void> _fetchEventDetails() async {
    print(
        'Fetching event details for user: ${widget.userId}, eventId: ${widget.eventId}');

    if (widget.eventId != null && widget.eventId!.isNotEmpty) {
      // Attempt to fetch from Firestore
      try {
        final docSnapshot = await _firestore
            .collection('users')
            .doc(widget.userId)
            .collection('events')
            .doc(widget.eventId)
            .get();

        if (docSnapshot.exists) {
          final data = docSnapshot.data()!;
          setState(() {
            _event = Event(
              id: null, // Local ID isn't relevant for Firestore data
              name: data['name'],
              date: data['date'],
              location: data['location'],
              description: data['description'],
              category: data['category'],
              eId: widget.eventId,
              isPublished: true,
              userId: widget.userId,
            );
            _isLoading = false;
          });
          print('Fetched event details from Firestore: $_event');
          return;
        }
      } catch (e) {
        print('Error fetching event details from Firestore: $e');
      }
    }

    // If Firestore fetching fails or eId is null, fetch from local storage
    try {
      List<Map<String, dynamic>> localEvents =
          await _localStorageService.getEventsForUser(widget.userId);
      for (var event in localEvents) {
        if (event['id'].toString() == widget.eventId) {
          // Compare ID as a string
          setState(() {
            _event = Event.fromMap(event);
            _isLoading = false;
          });
          print('Fetched event details from local storage: $_event');
          return;
        }
      }
    } catch (e) {
      print('Error fetching event details from local storage: $e');
    }

    // If no event is found in Firestore or local storage
    print('No event found in Firestore or local storage.');
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Event Details")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_event == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Event Details")),
        body: const Center(child: Text("No event details available.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_event!.name),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Date: ${_event!.date}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("Location: ${_event!.location}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("Description: ${_event!.description}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("Category: ${_event!.category}",
                style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
