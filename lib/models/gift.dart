class Gift {
  final int? id; // Local DB ID
  final String name;
  final String description;
  final String category;
  final double price;
  bool status;
  final String dueDate;
  final String? imagePath;
  final String? gId; // Firestore ID
  final int eventId; // Associated Event ID

  Gift({
    this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.status,
    required this.dueDate,
    this.imagePath,
    this.gId,
    required this.eventId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'imagepath': imagePath,
      'status': status ? 1 : 0, // Convert boolean to integer
      'gId': gId,
      'dueDate': dueDate,
      'eventId': eventId,
    };
  }

  factory Gift.fromMap(Map<String, dynamic> map) {
    return Gift(
      id: map['id'] as int?, // Ensure 'id' key is parsed properly
      gId: map['gId'] as String?,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      price: map['price'] is num ? (map['price'] as num).toDouble() : 0.0,
      status: map['status'] == 1, // Ensure status is parsed as a bool
      imagePath: map['imagepath'],
      dueDate: map['dueDate'] ?? '',
      eventId: map['eventId'],
    );
  }
}
