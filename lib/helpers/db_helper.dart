import '../data/models/place_suggestion.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/cupertino.dart';

class DbHelper {
  static Database? _db;
  static const int _version = 1;
  static const String _tableName = "history";

  static Future<void> initDB() async {
    if (_db != null) {
      debugPrint("Not null db");
      return;
    } else {
      String databasesPath = await getDatabasesPath();
      String _path = databasesPath + "history.db";
      _db = await openDatabase(_path, version: _version,
          onCreate: (Database db, int version) async {
        debugPrint("Create new db");
        await db.execute('CREATE TABLE $_tableName('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'place_id STRING, '
            'description STRING );');
      });

      debugPrint("_path:$_path");
    }
  }

  static Future<int> delete(id) async {
    debugPrint("delete");
    return await _db!.delete(_tableName, where: "id = ?", whereArgs: [id]);
  }

  static Future<int> deleteAll() async {
    debugPrint("delete All");
    return await _db!.delete(_tableName);
  }

  static Future<int> insert(PlaceSuggestion suggestion) async {
    debugPrint("insert");

    return await _db!.insert(_tableName, suggestion.toJson());
  }

  static Future<List<Map<String, dynamic>>> querySQL() async {
    debugPrint("Query SQL");
    return await _db!.query(_tableName);
  }
}
