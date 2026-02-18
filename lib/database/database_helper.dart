import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import '../models/category.dart';
import '../models/sub_category.dart';
import '../models/douaa.dart';

/// Asset path for the pre-created douaa.db. Place your file in assets/douaa.db.
const String _kDouaaDbAsset = 'assets/douaa.db';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static const int _dbVersion = 2;

  Future<Database> _initDatabase() async {
    final dbDir = await getDatabasesPath();
    final path = '$dbDir/douaa.db';
    final file = File(path);

    // If no database exists yet, copy from bundled asset (user's douaa.db) when present
    if (!file.existsSync()) {
      try {
        final bytes = await rootBundle.load(_kDouaaDbAsset);
        await file.writeAsBytes(
          bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
        );
      } catch (_) {
        // Asset not found (no douaa.db in assets/) or load error — create empty DB
        return await openDatabase(
          path,
          version: _dbVersion,
          onCreate: _onCreate,
          onConfigure: _onConfigure,
        );
      }
    }

    return await openDatabase(
      path,
      version: _dbVersion,
      onConfigure: _onConfigure,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute(
          'ALTER TABLE category ADD COLUMN sort_order INTEGER',
        );
      } catch (_) {
        // Column may already exist (e.g. from asset DB)
      }
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE category (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        sort_order INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE sub_category (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category_id INTEGER NOT NULL,
        FOREIGN KEY (category_id) REFERENCES category (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE douaa (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        sub_category_id INTEGER,
        douaa_ar TEXT NOT NULL,
        douaa_fr TEXT,
        reference TEXT,
        tags TEXT,
        is_favorite INTEGER DEFAULT 0,
        FOREIGN KEY (category_id) REFERENCES category (id) ON DELETE CASCADE,
        FOREIGN KEY (sub_category_id) REFERENCES sub_category (id) ON DELETE SET NULL
      )
    ''');
  }

  // ── Category CRUD ──

  Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert('category', category.toMap());
  }

  Future<List<Category>> getCategories() async {
    final db = await database;
    final maps = await db.rawQuery(
      'SELECT * FROM category ORDER BY COALESCE(sort_order, 999999) ASC, id ASC',
    );
    return maps.map((map) => Category.fromMap(map)).toList();
  }

  Future<int> getMaxCategorySortOrder() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COALESCE(MAX(sort_order), 0) AS max_order FROM category',
    );
    final maxOrder = result.first['max_order'];
    if (maxOrder is int) return maxOrder;
    if (maxOrder is num) return (maxOrder as num).toInt();
    return 0;
  }

  Future<void> updateCategorySortOrders(List<int> categoryIdsInOrder) async {
    final db = await database;
    final batch = db.batch();
    for (var i = 0; i < categoryIdsInOrder.length; i++) {
      batch.update(
        'category',
        {'sort_order': i},
        where: 'id = ?',
        whereArgs: [categoryIdsInOrder[i]],
      );
    }
    await batch.commit(noResult: true);
  }

  Future<int> updateCategory(Category category) async {
    final db = await database;
    return await db.update(
      'category',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete('category', where: 'id = ?', whereArgs: [id]);
  }

  /// Returns for each category id: sub_category count and douaa count.
  Future<Map<int, ({int subCount, int douaaCount})>> getCategoryCounts() async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT c.id,
        (SELECT COUNT(*) FROM sub_category sc WHERE sc.category_id = c.id) AS sub_count,
        (SELECT COUNT(*) FROM douaa d WHERE d.category_id = c.id) AS douaa_count
      FROM category c
    ''');
    final result = <int, ({int subCount, int douaaCount})>{};
    for (final m in maps) {
      final id = m['id'] as int?;
      if (id == null) continue;
      result[id] = (
        subCount: m['sub_count'] as int? ?? 0,
        douaaCount: m['douaa_count'] as int? ?? 0,
      );
    }
    return result;
  }

  // ── SubCategory CRUD ──

  Future<int> insertSubCategory(SubCategory subCategory) async {
    final db = await database;
    return await db.insert('sub_category', subCategory.toMap());
  }

  Future<List<SubCategory>> getSubCategoriesByCategoryId(int categoryId) async {
    final db = await database;
    final maps = await db.query(
      'sub_category',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'name ASC',
    );
    return maps.map((map) => SubCategory.fromMap(map)).toList();
  }

  Future<int> deleteSubCategory(int id) async {
    final db = await database;
    return await db.delete('sub_category', where: 'id = ?', whereArgs: [id]);
  }

  // ── Douaa CRUD ──

  Future<int> insertDouaa(Douaa douaa) async {
    final db = await database;
    return await db.insert('douaa', douaa.toMap());
  }

  Future<int> updateDouaa(Douaa douaa) async {
    final db = await database;
    return await db.update(
      'douaa',
      douaa.toMap(),
      where: 'id = ?',
      whereArgs: [douaa.id],
    );
  }

  Future<List<Douaa>> getDouaaByCategoryId(int categoryId) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT d.*, sc.name AS sub_category_name
      FROM douaa d
      LEFT JOIN sub_category sc ON d.sub_category_id = sc.id
      WHERE d.category_id = ?
      ORDER BY d.id DESC
    ''', [categoryId]);
    return maps.map((map) => Douaa.fromMap(map)).toList();
  }

  Future<int> toggleFavorite(int douaaId, bool isFavorite) async {
    final db = await database;
    return await db.update(
      'douaa',
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [douaaId],
    );
  }

  Future<int> deleteDouaa(int id) async {
    final db = await database;
    return await db.delete('douaa', where: 'id = ?', whereArgs: [id]);
  }

  // ── Favorites ──

  Future<List<Category>> getFavoriteCategories() async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT DISTINCT c.*
      FROM category c
      INNER JOIN douaa d ON d.category_id = c.id
      WHERE d.is_favorite = 1
      ORDER BY COALESCE(c.sort_order, 999999) ASC, c.id ASC
    ''');
    return maps.map((map) => Category.fromMap(map)).toList();
  }

  Future<List<Douaa>> getFavoriteDouaaByCategory(int categoryId) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT d.*, sc.name AS sub_category_name
      FROM douaa d
      LEFT JOIN sub_category sc ON d.sub_category_id = sc.id
      WHERE d.category_id = ? AND d.is_favorite = 1
      ORDER BY d.id DESC
    ''', [categoryId]);
    return maps.map((map) => Douaa.fromMap(map)).toList();
  }
}
