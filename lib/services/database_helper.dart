// lib/services/database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;

import '../models/workout_log_model.dart';
import '../models/user_model.dart';
import '../models/weight_log_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  DatabaseHelper._internal();
  static Database? _db;

  Future<Database> get db async => _db ??= await initDB();

  Future<Database> initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'data.db');
    return await openDatabase(
      path,
      version: 5, // 【還原】版本號改回 5
      onCreate: _createTables,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE workout_logs ADD COLUMN bodyPart TEXT');
        }
        if (oldVersion < 4) {
          await db.execute('''
            CREATE TABLE weight_logs(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              weight REAL NOT NULL,
              createdAt TEXT NOT NULL
            )
          ''');
        }
        if (oldVersion < 5) {
          await db.execute('ALTER TABLE users ADD COLUMN goalWeight TEXT');
        }
        // 【移除】移除了版本 6 的升級邏輯
      },
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // 建立 users 資料表
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        account TEXT UNIQUE,
        password TEXT,
        height TEXT,
        weight TEXT,
        age TEXT,
        bmi TEXT,
        fat TEXT,
        gender TEXT,
        bmr TEXT,
        goalWeight TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE workout_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exerciseName TEXT,
        totalSets INTEGER,
        completedAt TEXT,
        bodyPart TEXT 
      )
    ''');
    
    await db.execute('''
      CREATE TABLE weight_logs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        weight REAL NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.insert('users', {
      'account': 'admin', 'password': 'admin123', 'height': '170', 'weight': '60', 'age': '30', 'bmi': '20.76', 'fat': '15', 'gender': 'male', 'bmr': '1502.5',
    });
  }

  // --- User 相關方法 ---
  Future<void> insertUser(Map<String, dynamic> data) async {
    final db = await instance.db;
    await db.insert('users', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<bool> validateUser(String account, String password) async {
    final db = await instance.db;
    final result = await db.query('users', where: 'account = ? AND password = ?', whereArgs: [account, password]);
    return result.isNotEmpty;
  }

  Future<User?> getUserByAccount(String account) async {
    final db = await instance.db;
    final List<Map<String, dynamic>> maps = await db.query('users', where: 'account = ?', whereArgs: [account], limit: 1);
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  } 

  Future<int> updateUser(User user) async {
    final db = await instance.db;
    return await db.update('users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }

  // --- WorkoutLog 相關方法 ---
  Future<void> insertWorkoutLog(WorkoutLog log) async {
    final db = await instance.db;
    await db.insert('workout_logs', log.toMap());
  }

  Future<List<WorkoutLog>> getWorkoutLogs() async {
    final db = await instance.db;
    final List<Map<String, dynamic>> maps = await db.query('workout_logs', orderBy: 'completedAt DESC');
    return List.generate(maps.length, (i) => WorkoutLog.fromMap(maps[i]));
  }

  Future<int> deleteAllWorkoutLogs() async {
    final db = await instance.db;
    return await db.delete('workout_logs');
  }

  // --- WeightLog 相關方法 ---
  Future<void> insertWeightLog(WeightLog log) async {
    final db = await instance.db;
    await db.insert('weight_logs', log.toMap());
  }

  Future<List<WeightLog>> getWeightLogs() async {
    final db = await instance.db;
    final List<Map<String, dynamic>> maps = await db.query('weight_logs', orderBy: 'createdAt DESC');
    return List.generate(maps.length, (i) => WeightLog.fromMap(maps[i]));
  }
}