class Event {
  final int? id;
  final String name;
  final String date;
  final String location;
  final String description;
  final String category;
  final String status;
  final int userId;

  Event({
    this.id,
    required this.name,
    required this.date,
    required this.location,
    required this.description,
    required this.category,
    required this.status,
    required this.userId,
  });

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'location': location,
      'description': description,
      'category': category,
      'status': status,
      'userId': userId,
    };
  }

  // Convert from Map
  static Event fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      name: map['name'],
      date: map['date'],
      location: map['location'],
      description: map['description'],
      category: map['category'],
      status: map['status'],
      userId: map['userId'],
    );
  }
}
