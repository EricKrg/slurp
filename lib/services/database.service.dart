import 'package:slurp/model/SlurpAtom.dart';
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
      join(await getDatabasesPath(), 'slurp_database.db'),

      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        return db.execute(
          'CREATE TABLE slurp(id INTEGER PRIMARY KEY, value INTEGER, aim INTEGER, dateTime INTEGER)',
        );
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
  }

  DatabaseService();

  Future<void> insert(SlurpAtom slurpAtom) async {
    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    await database.insert(
      'slurp',
      slurpAtom.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<SlurpAtom?> getById(String id) async {
    final List<Map<String, dynamic>> res = await database.query(
      'slurp',
      where: 'id = ?',
      whereArgs: [id],
    );
    print("getting slurp");
    print(id);
    print(res);
    if (res.isEmpty) {
      print("is empty");
      return null;
    }
    print("return value");
    return SlurpAtom(res.first['value'], res.first['aim'],
        DateTime.fromMillisecondsSinceEpoch(res.first['dateTime']));
  }

  Future<void> update(SlurpAtom slurpAtom) async {
    await database.update(
      'slurp',
      slurpAtom.toMap(),
      // Ensure that the Dog has a matching id.
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [slurpAtom.id],
    );
  }
}
