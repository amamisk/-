
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Constants {
  final String dbName = "sqflite.db";
  final int dbVersion = 1;
  final String tableName = "address";
}

class Main_SQL_DB {

  /// データを保存する
  void saveData(String name,String ten,String six,String end) async {
    print('_saveData');
    /// データベースのパスを取得
    String dbFilePath = await getDatabasesPath();
    String path = join(dbFilePath, Constants().dbName);

    /// SQL文
    String query = 'INSERT INTO ${Constants().tableName}(name, ten, six, end) VALUES("$name", "$ten", "$six", "$end")';

    Database db = await openDatabase(path, version: Constants().dbVersion, onCreate: (Database db, int version) async {
      await db.execute(
          "CREATE TABLE IF NOT EXISTS ${Constants().tableName} (id INTEGER PRIMARY KEY, name TEXT, ten TEXT, six TEXT, end TEXT)"
      );
    });

    /// SQL 実行
    await db.transaction((txn) async {
      int id = await txn.rawInsert(query);
      print("保存成功 id: $id");
    });
  }

  /// 保存したデータを取り出す
  Future<List<Map>> getItems() async {
    print("getItems");
    /// データベースのパスを取得
    List<Widget> list = <Widget>[];
    String dbFilePath = await getDatabasesPath();
    String path = join (dbFilePath, Constants().dbName);

    /// テーブルがなければ作成する
    Database db = await openDatabase(
        path,
        version: Constants().dbVersion,
        onCreate: (Database db, int version) async {
          await db.execute("CREATE TABLE IF NOT EXISTS ${Constants().tableName} "
              "(id INTEGER PRIMARY KEY, name TEXT, ten TEXT, six TEXT, end TEXT)"
          );
        });

    /// SQLの実行
    return await db.rawQuery('SELECT * FROM ${Constants().tableName}');
  }

  ///　データベースアップデート
  void updateItems(int id, String name,String ten,String six,String end) async {
    print('updateItems');
    String dbFilePath = await getDatabasesPath();
    String path = join (dbFilePath, Constants().dbName);
    Database db = await openDatabase(path, version: Constants().dbVersion, onCreate: (Database db, int version) async {
      await db.execute(
          "CREATE TABLE IF NOT EXISTS ${Constants().tableName} (id INTEGER PRIMARY KEY, name TEXT, ten TEXT, six TEXT, end TEXT)"
      );
    });
    final Map<String, dynamic> new_recode = {
      'id': id,
      'name': name,
      'ten': ten,
      'six': six,
      'end': end
    };
    print('new_recode $new_recode');
    await db.update(Constants().tableName, new_recode, where: "id = ?", whereArgs: [id]);
  }

  /// データ件数取得
  Future<int> queryRowCount() async {
    String dbFilePath = await getDatabasesPath();
    String path = join (dbFilePath, Constants().dbName);
    Database db = await openDatabase(path, version: Constants().dbVersion, onCreate: (Database db, int version) async {
      await db.execute(
          "CREATE TABLE IF NOT EXISTS ${Constants().tableName} (id INTEGER PRIMARY KEY, name TEXT, ten TEXT, six TEXT, end TEXT)"
      );
    });
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM ${Constants().tableName}'));
  }
}

