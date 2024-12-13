import 'package:flutter/material.dart';
import '../controllers/gift_controller.dart';
import '../models/gift.dart';

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
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late TextEditingController _priceController;
  bool _isPledged = false; // Toggle status for the gift
  final GiftController _giftController = GiftController();
  bool _isGiftPledged = false; // To check if the gift is pledged when editing

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _categoryController = TextEditingController();
    _priceController = TextEditingController();

    if (widget.giftId != null) {
      _loadGiftDetails();
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
      });
    }
  }

  Future<void> _saveGift() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final category = _categoryController.text.trim();
    final price = double.tryParse(_priceController.text.trim());

    if (name.isEmpty ||
        description.isEmpty ||
        category.isEmpty ||
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
