// lib/database/db_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
CREATE TABLE notes ( 
  id $idType, 
  title $textType,
  content $textType,
  createdAt $textType,
  updatedAt $textType
  )
''');
  }

  // --- CRUD Methods --- (Slide 6)

  // Create
  Future<int> create(Note note) async {
    final db = await instance.database;
    return await db.insert('notes', note.toMap());
  }

  // Read All
  Future<List<Note>> readAllNotes() async {
    final db = await instance.database;
    final orderBy = 'updatedAt DESC';
    final result = await db.query('notes', orderBy: orderBy);
    return result.map((json) => Note.fromMap(json)).toList();
  }

  // Read One (Optional but good to have)
  Future<Note> readNote(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'notes',
      columns: ['id', 'title', 'content', 'createdAt', 'updatedAt'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Note.fromMap(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  // Update
  Future<int> update(Note note) async {
    final db = await instance.database;
    return db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  // Delete
  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}
