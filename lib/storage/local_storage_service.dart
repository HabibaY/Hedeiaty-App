import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  Database? _database;

  LocalStorageService._internal();

  factory LocalStorageService() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'hedieaty.db');
    print("Initializing database at path: $path");
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        print("Creating tables...");
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            uid TEXT UNIQUE,
            name TEXT,
            email TEXT,
            phoneNumber TEXT,
            notificationsEnabled INTEGER,
            password TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE events (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            date TEXT,
            location TEXT,
            description TEXT,
            category TEXT,
            userId TEXT,
            FOREIGN KEY (userId) REFERENCES users(id)
          )
        ''');
        await db.execute('''
          CREATE TABLE gifts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            description TEXT,
            category TEXT,
            price REAL,
            status INTEGER,
            eventId INTEGER,
            FOREIGN KEY (eventId) REFERENCES events(uid)
          )
        ''');
        await db.execute('''
          CREATE TABLE friends (
            userId INTEGER,
            friendId INTEGER,
            PRIMARY KEY (userId, friendId),
            FOREIGN KEY (userId) REFERENCES users (id),
            FOREIGN KEY (friendId) REFERENCES users (id)
          )
        ''');
        print("All tables created successfully.");
      },
    );
  }

  // User CRUD Operations
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('users');
  }

  Future<int> updateUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db
        .update('users', user, where: 'id = ?', whereArgs: [user['id']]);
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // Event CRUD Operations
  Future<int> insertEvent(Map<String, dynamic> event) async {
    final db = await database;
    return await db.insert('events', event);
  }

  Future<List<Map<String, dynamic>>> getEvents() async {
    final db = await database;
    return await db.query('events');
  }

  Future<List<Map<String, dynamic>>> getEventsForUser(String userId) async {
    final db = await database;
    return await db.query('events', where: 'userId = ?', whereArgs: [userId]);
  }

  Future<Map<String, dynamic>?> getEventById(int eventId) async {
    final db = await database;
    List<Map<String, dynamic>> result =
        await db.query('events', where: 'id = ?', whereArgs: [eventId]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateEvent(Map<String, dynamic> event) async {
    final db = await database;
    return await db
        .update('events', event, where: 'id = ?', whereArgs: [event['id']]);
  }

  Future<int> deleteEvent(int eventId) async {
    final db = await database;
    return await db.delete('events', where: 'id = ?', whereArgs: [eventId]);
  }

  // Gift CRUD Operations
  Future<int> insertGift(Map<String, dynamic> gift) async {
    final db = await database;
    return await db.insert('gifts', gift);
  }

  Future<List<Map<String, dynamic>>> getGifts() async {
    final db = await database;
    return await db.query('gifts');
  }

  Future<List<Map<String, dynamic>>> getGiftsForEvent(int eventId) async {
    final db = await database;
    return await db.query('gifts', where: 'eventId = ?', whereArgs: [eventId]);
  }

  Future<Map<String, dynamic>?> getGiftById(int giftId) async {
    final db = await database;
    List<Map<String, dynamic>> result =
        await db.query('gifts', where: 'id = ?', whereArgs: [giftId]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateGift(Map<String, dynamic> gift) async {
    final db = await database;
    return await db
        .update('gifts', gift, where: 'id = ?', whereArgs: [gift['id']]);
  }

  Future<int> deleteGift(int id) async {
    final db = await database;
    return await db.delete('gifts', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getGiftsByStatusForEvent(
      int eventId, int status) async {
    final db = await database;
    return await db.query('gifts',
        where: 'eventId = ? AND status = ?', whereArgs: [eventId, status]);
  }

  Future<int> countGiftsForEvent(int eventId) async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM gifts WHERE eventId = ?', [eventId]);
    return result.first['count'] as int;
  }

  // Friend Operations
  Future<int> addFriend(int userId, int friendId) async {
    final db = await database;
    return await db.insert('friends', {'userId': userId, 'friendId': friendId});
  }

  Future<int> removeFriend(int userId, int friendId) async {
    final db = await database;
    return await db.delete(
      'friends',
      where: 'userId = ? AND friendId = ?',
      whereArgs: [userId, friendId],
    );
  }

  Future<List<Map<String, dynamic>>> getFriends(int userId) async {
    final db = await database;
    return await db.query(
      'friends',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  Future<bool> isFriend(int userId, int friendId) async {
    final db = await database;
    final result = await db.query(
      'friends',
      where: 'userId = ? AND friendId = ?',
      whereArgs: [userId, friendId],
    );
    return result.isNotEmpty;
  }

  // Database Reset
  Future<void> deleteDatabaseFile() async {
    String path = join(await getDatabasesPath(), 'hedieaty.db');
    await deleteDatabase(path);
  }
}
