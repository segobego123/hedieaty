import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  DatabaseService._internal();

  factory DatabaseService() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'gift_management.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        preferences TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE Events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        date TEXT NOT NULL,
        location TEXT,
        description TEXT,
        userId INTEGER NOT NULL,
        FOREIGN KEY (userId) REFERENCES Users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE Gifts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        category TEXT,
        price REAL NOT NULL,
        status TEXT NOT NULL,
        eventId INTEGER NOT NULL,
        FOREIGN KEY (eventId) REFERENCES Events (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE Friends (
        userId INTEGER NOT NULL,
        friendId INTEGER NOT NULL,
        PRIMARY KEY (userId, friendId),
        FOREIGN KEY (userId) REFERENCES Users (id) ON DELETE CASCADE,
        FOREIGN KEY (friendId) REFERENCES Users (id) ON DELETE CASCADE
      )
    ''');
  }

  /// Insert a user
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('Users', user, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Fetch all users
  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('Users');
  }

  /// Insert an event
  Future<int> insertEvent(Map<String, dynamic> event) async {
    final db = await database;
    return await db.insert('Events', event, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Fetch all events for a specific user
  Future<List<Map<String, dynamic>>> getEvents(int userId) async {
    final db = await database;
    return await db.query(
      'Events',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  /// Insert a gift
  Future<int> insertGift(Map<String, dynamic> gift) async {
    final db = await database;
    return await db.insert('Gifts', gift, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Fetch gifts for a specific event
  Future<List<Map<String, dynamic>>> getGifts(int eventId) async {
    final db = await database;
    return await db.query(
      'Gifts',
      where: 'eventId = ?',
      whereArgs: [eventId],
    );
  }

  /// Insert a friend connection
  Future<int> addFriend(int userId, int friendId) async {
    final db = await database;
    return await db.insert(
      'Friends',
      {'userId': userId, 'friendId': friendId},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// Fetch all friends of a user
  Future<List<Map<String, dynamic>>> getFriends(int userId) async {
    final db = await database;
    return await db.query(
      'Friends',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  /// Update gift status
  Future<int> updateGiftStatus(int giftId, String newStatus) async {
    final db = await database;
    return await db.update(
      'Gifts',
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [giftId],
    );
  }

  /// Delete an event and associated gifts
  Future<int> deleteEvent(int eventId) async {
    final db = await database;
    return await db.delete(
      'Events',
      where: 'id = ?',
      whereArgs: [eventId],
    );
  }

  /// Delete a user and cascade their data
  Future<int> deleteUser(int userId) async {
    final db = await database;
    return await db.delete(
      'Users',
      where: 'id = ?',
      whereArgs: [userId],
    );
  }
}