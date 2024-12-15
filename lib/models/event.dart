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
      id: map['id'], // Nullable, only present in local storage
      name: map['name'] ?? '',
      date: map['date'] ?? '',
      location: map['location'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      eId: map['eId'], // Nullable, only present if synced with Firestore
      isPublished: map['isPublished'] == 1, // Default to false if not present
      userId: map['userId'] ?? '',
    );
  }
  factory Event.fromFirestore(
      Map<String, dynamic> map, String documentId, String userId) {
    return Event(
      id: null, // Local ID is not present in Firestore
      name: map['name'] ?? '',
      date: map['date'] ?? '',
      location: map['location'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      eId: documentId, // Use Firestore document ID
      isPublished: true, // Firestore events are considered published
      userId: userId, // Pass the userId explicitly
    );
  }
}
