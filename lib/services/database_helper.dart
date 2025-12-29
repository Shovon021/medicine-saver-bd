import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/models.dart';

/// Singleton service for managing the local medicine database.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// Returns the database instance, initializing it if necessary.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('medicines.db');
    return _database!;
  }

  /// Copies the pre-bundled database from assets to the app's documents directory.
  Future<Database> _initDB(String filePath) async {
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, filePath);

    // Check if the database already exists
    final bool exists = await databaseExists(path);

    if (!exists) {
      // Make sure the parent directory exists
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy from asset
      try {
        final ByteData data =
            await rootBundle.load(join('assets', 'db', 'medicines.db'));
        final List<int> bytes =
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

        // Write bytes to the file
        await File(path).writeAsBytes(bytes, flush: true);
      } catch (e) {
        // If no bundled DB exists, create an empty one with schema
        return await _createEmptyDB(path);
      }
    }

    // Open the database
    return await openDatabase(path, readOnly: false);
  }

  /// Creates an empty database with the required schema (for development).
  Future<Database> _createEmptyDB(String path) async {
    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        // Generics table
        await db.execute('''
          CREATE TABLE IF NOT EXISTS generics (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            indication TEXT,
            dosage_info TEXT,
            side_effects TEXT
          )
        ''');

        // Manufacturers table
        await db.execute('''
          CREATE TABLE IF NOT EXISTS manufacturers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            country TEXT
          )
        ''');

        // Brands table
        await db.execute('''
          CREATE TABLE IF NOT EXISTS brands (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            generic_id INTEGER NOT NULL,
            manufacturer_id INTEGER,
            strength TEXT,
            dosage_form TEXT,
            price REAL,
            pack_size TEXT,
            FOREIGN KEY (generic_id) REFERENCES generics (id),
            FOREIGN KEY (manufacturer_id) REFERENCES manufacturers (id)
          )
        ''');

        // Create full-text search virtual table for fast searching
        await db.execute('''
          CREATE VIRTUAL TABLE IF NOT EXISTS brands_fts USING fts5(
            name, 
            content='brands', 
            content_rowid='id'
          )
        ''');
      },
    );
    return db;
  }

  /// Searches for brands by name OR generic name (supports partial matching).
  Future<List<Brand>> searchBrands(String query) async {
    final db = await database;
    final String searchQuery = '%${query.toLowerCase()}%';

    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT 
        b.id, b.name, b.generic_id, b.manufacturer_id, b.strength, 
        b.dosage_form, b.price, b.pack_size,
        g.name as generic_name,
        m.name as manufacturer_name
      FROM brands b
      LEFT JOIN generics g ON b.generic_id = g.id
      LEFT JOIN manufacturers m ON b.manufacturer_id = m.id
      WHERE LOWER(b.name) LIKE ? OR LOWER(g.name) LIKE ?
      ORDER BY b.price ASC
      LIMIT 50
    ''', [searchQuery, searchQuery]);

    return results.map((map) => Brand.fromMap(map)).toList();
  }

  /// Finds all brands containing the same generic as the given brand.
  Future<List<Brand>> findAlternatives(int genericId) async {
    final db = await database;

    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT 
        b.id, b.name, b.generic_id, b.manufacturer_id, b.strength, 
        b.dosage_form, b.price, b.pack_size,
        g.name as generic_name,
        m.name as manufacturer_name
      FROM brands b
      LEFT JOIN generics g ON b.generic_id = g.id
      LEFT JOIN manufacturers m ON b.manufacturer_id = m.id
      WHERE b.generic_id = ?
      ORDER BY b.price ASC
    ''', [genericId]);

    return results.map((map) => Brand.fromMap(map)).toList();
  }

  /// Smart search: finds a brand by query, then returns ALL alternatives with same generic.
  /// This enables the core feature: search "Napa" → see all Paracetamol brands sorted by price.
  Future<List<Brand>> searchWithAlternatives(String query) async {
    // Step 1: Find brands matching the query
    final brands = await searchBrands(query);
    if (brands.isEmpty) return [];
    
    // Step 2: Get the generic_id of the first match
    final genericId = brands.first.genericId;
    
    // Step 3: Return ALL brands with the same generic, sorted by price
    return await findAlternatives(genericId);
  }

  /// Gets unique strength values from a list of brands for filtering.
  static List<String> getUniqueStrengths(List<Brand> brands) {
    final strengths = brands
        .where((b) => b.strength != null && b.strength!.isNotEmpty)
        .map((b) => b.strength!)
        .toSet()
        .toList();
    strengths.sort();
    return strengths;
  }

  /// Gets a specific generic by ID.
  Future<Generic?> getGeneric(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'generics',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return Generic.fromMap(results.first);
  }

  /// Closes the database connection.
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
