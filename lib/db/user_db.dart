


//db/user_db.dart

import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:the_shot2/models/user_table_db.dart';
import 'package:crypto/crypto.dart';



class UserDatabase {
  static final UserDatabase instance = UserDatabase._init();

  static Database? _database;

  UserDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('user.db');
    return _database!;
  }

  Future<void> initDatabase() async {
    await _initDB('user.db');
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final textType = 'TEXT NOT NULL';
    final charType = 'CHAR NOT NULL';
    final integerType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE $tableUsers (
      ${UserFields.id} $idType,
      ${UserFields.first_name} $textType,
      ${UserFields.last_name} $textType,
      ${UserFields.username} $charType,
      ${UserFields.email} $charType,
      ${UserFields.password} $charType,
      ${UserFields.phone_num} $integerType,
      ${UserFields.address} $textType
      )
    ''');
  }

  Future<Users> create(Users user) async{
    final db = await instance.database;

    final id = await db.insert(tableUsers, user.tojson());
    return user.copy(id: id);
  }

  Future close() async{
    final db = await instance.database;

    db.close();
  }

  Future<Users?> authenticateUser(String username, String password) async {
    final db = await instance.database;
    print('Authenticating user: $username');

    // Hardcoded username and password for testing
     final hardcodedUsername = 'johndoe';
     final hardcodedPassword = 'password123';

    // Check if the provided username and password match the hardcoded values
     if (username == hardcodedUsername && password == hardcodedPassword) {
        // Create a mock user object using the hardcoded values
       final mockUser = Users(
        id: 1, // Assuming an ID for the mock user
        first_name: 'John',
        last_name: 'Doe',
        username: username,
        email: 'johndoe@example.com',
        password: password,
        phone_num: 1234567890,
        address: '123 Main St, City',
      );

      // Print user data for debugging
      mockUser.printUserData(UserFields());

      // Return the mock user as if it were retrieved from the database
       return mockUser; }

    // Hash the provided password using a cryptographic hash function (e.g., SHA-256)
    final hashedPassword = sha256.convert(utf8.encode(password)).toString();

    final List<Map<String, dynamic>> result = await db.query(
      tableUsers,
      where: '${UserFields.username} = ? AND ${UserFields.password} = ?',
      whereArgs: [username, hashedPassword],
    );
    print('Query result: $result');

    if (result.isNotEmpty) {
      final user = Users(
        id: result[0][UserFields.id],
        first_name: result[0][UserFields.first_name],
        last_name: result[0][UserFields.last_name],
        username: result[0][UserFields.username],
        email: result[0][UserFields.email],
        password: result[0][UserFields.password],
        phone_num: result[0][UserFields.phone_num],
        address: result[0][UserFields.address],
      );

      user.printUserData(user); // Call printUserData() to print user data for debugging
      return user;
    } else {
      print('User not found'); // Print user not found for debugging
      return null;
    }
  }
  Future<void> insertSampleUsers() async {
    // Get a reference to the database
    final db = await instance.database;

    // Insert sample user records
    final sampleUsers = [
      {
        UserFields.first_name: 'John',
        UserFields.last_name: 'Doe',
        UserFields.username: 'sarah',
        UserFields.email: 'johndoe@example.com',
        UserFields.password: '123',
        UserFields.phone_num: 1234567890,
        UserFields.address: '123 Main St, City',
      },
      // Add more sample user records as needed
    ];

    for (final user in sampleUsers) {
      await db.insert(
        tableUsers,
        user,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    print('Sample user data inserted successfully.');
  }


}


