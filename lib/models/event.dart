class Event {
  final int? id; // Local database ID
  final String name;
  final String date;
  final String location;
  final String description;
  final String category;
  final String? eId; // Firestore ID
  final bool isPublished;
  final String userId;

  Event({
    this.id,
    required this.name,
    required this.date,
    required this.location,
    required this.description,
    required this.category,
    this.eId, // Allow null initially
    required this.isPublished,
    required this.userId,
  });

  // Convert Event to Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'location': location,
      'description': description,
      'category': category,
      'eId': eId, // Include Firestore ID
      'isPublished': isPublished ? 1 : 0, // Store as integer (SQLite)
      'userId': userId,
    };
  }

  // Convert Map from database to Event object
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      name: map['name'],
      date: map['date'],
      location: map['location'],
      description: map['description'],
      category: map['category'],
      eId: map['eId'], // Fetch Firestore ID
      isPublished: map['isPublished'] == 1, // Convert integer to boolean
      userId: map['userId'],
    );
  }
}
