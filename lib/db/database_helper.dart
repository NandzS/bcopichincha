import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cajero.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE usuarios(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT,
      saldo REAL
    )
    ''');
  }

  Future<int> insertUsuario(Map<String, dynamic> usuario) async {
    final db = await instance.database;
    return await db.insert('usuarios', usuario);
  }

  Future<List<Map<String, dynamic>>> getUsuarios() async {
    final db = await instance.database;
    return await db.query('usuarios');
  }

  Future<int> updateUsuario(int id, double nuevoSaldo) async {
    final db = await instance.database;
    return await db.update('usuarios', {'saldo': nuevoSaldo},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteUsuario(int id) async {
    final db = await instance.database;
    return await db.delete('usuarios', where: 'id = ?', whereArgs: [id]);
  }
}