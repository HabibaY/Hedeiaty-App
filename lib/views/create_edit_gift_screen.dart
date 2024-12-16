import 'package:flutter/material.dart';
import '../controllers/gift_controller.dart';
import '../models/gift.dart';
import '../storage/local_storage_service.dart'; // Import your local storage service

class CreateEditGiftScreen extends StatefulWidget {
  final int? giftId; // Optional for editing purposes
  final int eventId; // Associated Event ID

  const CreateEditGiftScreen({
    super.key,
    this.giftId,
    required this.eventId,
  });

  @override
  _CreateEditGiftScreenState createState() => _CreateEditGiftScreenState();
}

class _CreateEditGiftScreenState extends State<CreateEditGiftScreen> {
  final LocalStorageService _localStorageService =
      LocalStorageService(); // Initialize the local storage service

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late TextEditingController _priceController;
  late TextEditingController _dueDateController;
  DateTime? _eventDate; // To store the fetched event date
  bool _isLoading = true; // For loading state
  bool _isPledged = false; // Toggle status for the gift
  final GiftController _giftController = GiftController();
  bool _isGiftPledged = false; // To check if the gift is pledged when editing

  @override
  void initState() {
    super.initState();
    _fetchEventDateLocally();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _categoryController = TextEditingController();
    _priceController = TextEditingController();
    _dueDateController = TextEditingController();

    if (widget.giftId != null) {
      _loadGiftDetails();
    }
  }

  Future<void> _fetchEventDateLocally() async {
    try {
      // Fetch the event by eventId from local storage
      final event = await _localStorageService.getEventById(widget.eventId);

      if (event != null) {
        setState(() {
          _eventDate = DateTime.parse(event['date']); // Parse event date
          _isLoading = false; // Stop loading
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Event not found locally."),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context); // Exit if the event doesn't exist locally
      }
    } catch (e) {
      print("Error fetching event date locally: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to fetch event details locally."),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context); // Exit on error
    }
  }

  Future<void> _loadGiftDetails() async {
    final gift = await _giftController.getGiftById(widget.giftId!);
    if (gift != null) {
      setState(() {
        _nameController.text = gift.name;
        _descriptionController.text = gift.description;
        _categoryController.text = gift.category ?? "";
        _priceController.text = gift.price.toString();
        _isPledged = gift.status;
        _isGiftPledged = gift.status; // Set the initial pledged status
        _dueDateController.text = gift.dueDate;
      });
    }
  }

  Future<void> _saveGift() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final category = _categoryController.text.trim();
    final price = double.tryParse(_priceController.text.trim());
    final duedate = _dueDateController.text.trim();

    if (name.isEmpty ||
        description.isEmpty ||
        category.isEmpty ||
        duedate.isEmpty ||
        price == null) {
      _showSnackbar("All fields are required.");
      return;
    }

    if (widget.giftId == null) {
      // Add new gift
      await _giftController.addGift(
        name: name,
        description: description,
        category: category,
        price: price,
        status: _isPledged,
        dueDate: duedate,
        eventId: widget.eventId,
      );
    } else {
      // Update existing gift
      final gift = Gift(
        id: widget.giftId,
        name: name,
        description: description,
        category: category,
        price: price,
        status: _isPledged,
        dueDate: duedate,
        eventId: widget.eventId,
      );
      await _giftController.updateGift(gift);
    }

    Navigator.pop(context, true); // Return to the Gift List Screen
  }

  void _showSnackbar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final isEditable = !_isGiftPledged; // Check if the gift can be edited

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.giftId != null ? "Edit Gift" : "Create Gift"),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (!isEditable)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Text(
                        "This gift is pledged and cannot be modified.",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Gift Name"),
                  enabled: isEditable, // Disable if pledged
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: "Description"),
                  enabled: isEditable, // Disable if pledged
                ),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: "Category"),
                  enabled: isEditable, // Disable if pledged
                ),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Price"),
                  enabled: isEditable, // Disable if pledged
                ),
                TextFormField(
                  controller: _dueDateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Due Date",
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    DateTime? selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );

                    if (selectedDate != null) {
                      // Validate that due date is after the event date
                      if (selectedDate.isBefore(_eventDate!)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Due date must be after the event date (${_eventDate!.toLocal().toString().split(' ')[0]}).",
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } else {
                        // Update the due date field if validation passes
                        setState(() {
                          _dueDateController.text =
                              "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
                        });
                      }
                    }
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Gift is Pledged"),
                    Switch(
                      value: _isPledged,
                      onChanged: isEditable
                          ? (value) {
                              setState(() {
                                _isPledged = value;
                              });
                            }
                          : null, // Disable if pledged
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed:
                      isEditable ? _saveGift : null, // Disable if pledged
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEditable ? Colors.purple : Colors.grey,
                  ),
                  child: const Text(
                    "Save Gift",
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
