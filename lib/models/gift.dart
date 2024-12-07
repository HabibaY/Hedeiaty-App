class Gift {
  final int? id;
  final String name;
  final String description;
  final String category;
  final double price;
  final bool status; // Changed to boolean
  final int eventId;

  Gift({
    this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.status,
    required this.eventId,
  });

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'status': status ? 1 : 0, // Convert boolean to integer
      'eventId': eventId,
    };
  }

  // Convert from Map
  static Gift fromMap(Map<String, dynamic> map) {
    return Gift(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      category: map['category'],
      price: map['price'],
      status: map['status'] == 1, // Convert integer to boolean
      eventId: map['eventId'],
    );
  }
}
