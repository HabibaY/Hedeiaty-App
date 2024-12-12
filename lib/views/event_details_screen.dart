import 'package:flutter/material.dart';
import '../models/event.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';

class EventDetailsScreen extends StatelessWidget {
  final Event event;
  const EventDetailsScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final eventId = Provider.of<EventProvider>(context).eventId;
    if (eventId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Event Details")),
        body: const Center(child: Text("No event selected.")),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(event.name),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Date: ${event.date}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("Location: ${event.location}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("Description: ${event.description}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("Category: ${event.category}",
                style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
