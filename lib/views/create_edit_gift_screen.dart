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
      await _giftController.addGift(
        name: name,
        description: description,
        category: category,
        price: price,
        status: _isPledged,
        eventId: widget.eventId,
      );
    } else {
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
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Gift Name"),
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: "Description"),
                ),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: "Category"),
                ),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Price"),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Gift is Pledged"),
                    Switch(
                      value: _isPledged,
                      onChanged: (value) {
                        setState(() {
                          _isPledged = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveGift,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
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
