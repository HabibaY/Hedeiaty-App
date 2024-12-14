class Gift {
  final int? id; // Local DB ID
  final String name;
  final String description;
  final String category;
  final double price;
  final bool status;
  final String? gId; // Firestore ID
  final int eventId; // Associated Event ID

  Gift({
    this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.status,
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
      'status': status ? 1 : 0, // Convert boolean to integer
      'gId': gId,
      'eventId': eventId,
    };
  }

  static Gift fromMap(Map<String, dynamic> map) {
    return Gift(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      category: map['category'],
      price: map['price'],
      status: map['status'] == 1, // Convert integer to boolean
      gId: map['gId'],
      eventId: map['eventId'],
    );
  }
}
