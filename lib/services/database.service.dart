import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:slurp/model/DatabaseObject.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static DatabaseService get instance {
    _instance ??= DatabaseService._init();
    return _instance!;
  }

  late Database database;
  static DatabaseService? _instance;
  DatabaseService._init();

  Future<void> init() async {
    // Open the database and store the reference.
    database = await openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'slurp2.db'),

      onCreate: (db, version) async {
        // Run the CREATE TABLE statement on the database.

        await db.execute(
          'CREATE TABLE notificationplan(id STRING PRIMARY KEY, open TEXT, closed TEXT, tmpClosed TEXT, shouldRemind BOOLEAN, planFrom INTEGER)',
        );
        await db.execute(
          'CREATE TABLE slurp(id INTEGER PRIMARY KEY, value INTEGER, aim INTEGER, dateTime INTEGER, dayMap TEXT)',
        );
        return;
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
  }

  DatabaseService();

  Future<void> insert<T extends DatabaseObject>(T obj, String table) async {
    try {
      await database.insert(
        table,
        obj.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print("Error inserting Database Object ${e.toString()}");
    }
  }

  Future<T?> getById<T>({required String id, required String table}) async {
    final List<Map<String, dynamic>> res = await database.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (res.isEmpty) {
      return null;
    }
    final t = make<T>(res.first);
    return t;
  }

  Future<void> update<T extends DatabaseObject>(
      {required T obj, required String table}) async {
    await database.update(
      table,
      obj.toMap(),
      where: 'id = ?',
      whereArgs: [obj.id],
    );
  }
}
