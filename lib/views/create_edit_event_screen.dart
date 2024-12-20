import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/event_controller.dart';
import '../models/event.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';

class CreateEditEventScreen extends StatefulWidget {
  final int? eventId; // Optional for editing purposes
  final DateTime? initialDate;
  final String userId; // To associate event with the current user

  const CreateEditEventScreen({
    super.key,
    this.eventId,
    this.initialDate,
    required this.userId,
  });

  @override
  _CreateEditEventScreenState createState() => _CreateEditEventScreenState();
}

class _CreateEditEventScreenState extends State<CreateEditEventScreen> {
  late TextEditingController _dateController;
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  String? _category;
  final EventController _eventController = EventController();
  bool _isPledged = false; // Flag to prevent editing

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _locationController = TextEditingController();
    _descriptionController = TextEditingController();
    _dateController = TextEditingController();

    if (widget.eventId != null) {
      _loadEventDetails();
    } else if (widget.initialDate != null) {
      _dateController.text =
          DateFormat('yyyy-MM-dd').format(widget.initialDate!);
    }
  }

  Future<void> _loadEventDetails() async {
    final event = await _eventController.getEventById(widget.eventId!);
    if (event != null) {
      setState(() {
        _nameController.text = event.name;
        _locationController.text = event.location;
        _descriptionController.text = event.description;
        _dateController.text = event.date;
        _category = event.category;
        _isPledged = event.isPublished; // Mark event as pledged
        // `eId` is used internally; no UI interaction is necessary.
      });
    }
  }

  Future<void> _saveEvent() async {
    final name = _nameController.text.trim();
    final date = _dateController.text.trim();
    final location = _locationController.text.trim();
    final description = _descriptionController.text.trim();

    if (name.isEmpty || date.isEmpty || location.isEmpty || _category == null) {
      _showSnackbar("All fields are required.");
      return;
    }

    if (widget.eventId == null) {
      // Add a new event
      await _eventController.addEvent(
        name: name,
        date: date,
        location: location,
        description: description,
        category: _category!,
        isPublished: false, // New events are not published by default
        userId: widget.userId,
        eId: null, // Firestore ID is null for new events
      );
    } else {
      // Update an existing event
      final event = await _eventController.getEventById(widget.eventId!);
      if (event != null) {
        final updatedEvent = Event(
          id: event.id,
          name: name,
          date: date,
          location: location,
          description: description,
          category: _category!,
          isPublished: event.isPublished, // Retain the published state
          eId: event.eId, // Retain Firestore ID if it exists
          userId: widget.userId,
        );
        await _eventController.updateEvent(updatedEvent);
      } else {
        _showSnackbar("Event not found.");
      }
    }

    Navigator.pop(context, true); // Return to Event List Screen
  }

  void _showSnackbar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventId != null ? "Edit Event" : "Create Event"),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Warning Banner for Pledged Events
                if (_isPledged)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Text(
                      "This event is published and cannot be edited.",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Event Name"),
                  enabled: !_isPledged,
                ),
                TextFormField(
                  controller: _dateController,
                  decoration: const InputDecoration(labelText: "Date"),
                  onTap: !_isPledged
                      ? () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: widget.initialDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            _dateController.text =
                                DateFormat('yyyy-MM-dd').format(pickedDate);
                          }
                        }
                      : null,
                  readOnly: true,
                ),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: "Location"),
                  enabled: !_isPledged,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: "Description"),
                  enabled: !_isPledged,
                ),
                DropdownButtonFormField(
                  value: _category,
                  items: const [
                    DropdownMenuItem(
                        value: "Birthday", child: Text("Birthday")),
                    DropdownMenuItem(value: "Wedding", child: Text("Wedding")),
                    DropdownMenuItem(
                        value: "Engagement", child: Text("Engagement")),
                    DropdownMenuItem(
                        value: "Graduation", child: Text("Graduation")),
                    DropdownMenuItem(value: "Holiday", child: Text("Holiday")),
                    DropdownMenuItem(value: "Other", child: Text("Other")),
                  ],
                  decoration: const InputDecoration(labelText: "Category"),
                  onChanged: !_isPledged
                      ? (value) {
                          setState(() {
                            _category = value as String;
                          });
                        }
                      : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: !_isPledged ? _saveEvent : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isPledged ? Colors.grey : Colors.purple,
                  ),
                  child: const Text(
                    "Save Event",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
