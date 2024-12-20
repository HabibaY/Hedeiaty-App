import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_application_1/storage/local_storage_service.dart';

void main() {
  late LocalStorageService storageService;
  late Database db;

  // Setup sqflite for testing
  setUpAll(() {
    // Initialize FFI
    sqfliteFfiInit();
    // Set global factory
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // Reinitialize the LocalStorageService and database for each test
    storageService = LocalStorageService();
    db = await storageService.database;
    print("Database initialized for test.");
  });

  tearDown(() async {
    // Close and delete the database after each test
    if (db.isOpen) {
      await db.close();
      print("Database closed.");
    }
    await storageService.deleteDatabaseFile();
    print("Database file deleted.");
  });

  group('Database Initialization', () {
    test('should create database successfully', () async {
      expect(db, isNotNull);
      expect(db.isOpen, true);
    });

    test('should create all required tables', () async {
      final tables = await db
          .query('sqlite_master', where: 'type = ?', whereArgs: ['table']);

      expect(tables.map((t) => t['name']).toList(),
          containsAll(['users', 'events', 'gifts']));
    });
  });

  group('User Operations', () {
    final testUser = {
      'uid': 'test123',
      'name': 'Test User',
      'email': 'test@example.com',
      'phoneNumber': '+1234567890',
      'notificationsEnabled': 1,
      'password': 'hashedPassword',
      'profileImagePath': '/path/to/image.jpg'
    };

    test('should insert user successfully', () async {
      final id = await storageService.insertUser(testUser);
      expect(id, isPositive);
    });

    test('should retrieve inserted user', () async {
      // Insert test user
      final id = await storageService.insertUser(testUser);

      // Retrieve users
      final users = await storageService.getUsers();

      expect(users, hasLength(1));
      expect(users.first['name'], equals(testUser['name']));
    });

    test('should update user successfully', () async {
      // Insert user
      final id = await storageService.insertUser(testUser);

      // Update user
      final updatedUser = Map<String, dynamic>.from(testUser)
        ..addAll({'id': id, 'name': 'Updated Name'});

      final updateResult = await storageService.updateUser(updatedUser);
      expect(updateResult, 1);

      // Verify update
      final users = await storageService.getUsers();
      expect(users.first['name'], 'Updated Name');
    });

    test('should delete user successfully', () async {
      // Insert user
      final id = await storageService.insertUser(testUser);

      // Delete user
      final deleteResult = await storageService.deleteUser(id);
      expect(deleteResult, 1);

      // Verify deletion
      final users = await storageService.getUsers();
      expect(users, isEmpty);
    });
  });

  group('Event Operations', () {
    final testEvent = {
      'name': 'Test Event',
      'date': '2024-12-25',
      'location': 'Test Location',
      'description': 'Test Description',
      'category': 'Test Category',
      'userId': 'user123',
      'isPublished': 0,
    };

    test('should insert and retrieve event', () async {
      final id = await storageService.insertEvent(testEvent);
      expect(id, isPositive);

      final events = await storageService.getEvents();
      expect(events, hasLength(1));
      expect(events.first['name'], testEvent['name']);
    });

    test('should get events for specific user', () async {
      await storageService.insertEvent(testEvent);

      final userEvents = await storageService.getEventsForUser('user123');
      expect(userEvents, hasLength(1));
      expect(userEvents.first['userId'], 'user123');
    });

    test('should mark event as published', () async {
      final id = await storageService.insertEvent(testEvent);
      await storageService.markEventAsPublished(id, 'firebase123');

      final event = await storageService.getEventById(id);
      expect(event?['isPublished'], 1);
      expect(event?['eId'], 'firebase123');
    });
  });

  group('Gift Operations', () {
    late int testEventId;
    final testGift = {
      'name': 'Test Gift',
      'description': 'Test Description',
      'category': 'Test Category',
      'price': 99.99,
      'status': 0,
      'dueDate': '2024-12-25',
      'eventId': 1 // Will be updated with actual event ID
    };

    setUp(() async {
      // Create a test event first
      testEventId = await storageService.insertEvent({
        'name': 'Test Event',
        'date': '2024-12-25',
        'location': 'Test Location',
        'description': 'Test Description',
        'category': 'Test Category',
        'userId': 'user123',
        'isPublished': 0,
      });
      testGift['eventId'] = testEventId;
    });

    test('should insert and retrieve gift', () async {
      final id = await storageService.insertGift(testGift);
      expect(id, isPositive);

      final gifts = await storageService.getGifts();
      expect(gifts, hasLength(1));
      expect(gifts.first['name'], testGift['name']);
    });

    test('should get gifts for specific event', () async {
      await storageService.insertGift(testGift);

      final eventGifts = await storageService.getGiftsForEvent(testEventId);
      expect(eventGifts, hasLength(1));
      expect(eventGifts.first['eventId'], testEventId);
    });

    test('should count gifts for event', () async {
      await storageService.insertGift(testGift);
      await storageService
          .insertGift(Map.from(testGift)..['name'] = 'Second Gift');

      final count = await storageService.countGiftsForEvent(testEventId);
      expect(count, 2);
    });

    test('should get gifts by status', () async {
      await storageService.insertGift(testGift);

      final availableGifts =
          await storageService.getGiftsByStatusForEvent(testEventId, 0);
      expect(availableGifts, hasLength(1));

      final pledgedGifts =
          await storageService.getGiftsByStatusForEvent(testEventId, 1);
      expect(pledgedGifts, isEmpty);
    });
  });
}
