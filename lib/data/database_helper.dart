import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'pharmaone.db');

    if (!await Directory(dirname(path)).exists()) {
      await Directory(dirname(path)).create(recursive: true);
    }

    final db = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT,
        role TEXT,
        fullName TEXT,
        createdAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        category TEXT,
        barcode TEXT,
        purchasePrice REAL,
        salePrice REAL,
        quantity INTEGER,
        manufactureDate TEXT,
        expiryDate TEXT,
        supplier TEXT,
        createdAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE suppliers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        phone TEXT,
        address TEXT,
        note TEXT,
        createdAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE clients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        phone TEXT,
        address TEXT,
        createdAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoiceNumber TEXT,
        clientName TEXT,
        total REAL,
        discount REAL,
        tax REAL,
        createdAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE sale_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        saleId INTEGER,
        productId INTEGER,
        productName TEXT,
        quantity INTEGER,
        unitPrice REAL,
        total REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE stock_movements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT,
        productId INTEGER,
        quantity INTEGER,
        note TEXT,
        createdAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE pharmacy_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        address TEXT,
        phone TEXT,
        currency TEXT,
        taxRate REAL,
        logoPath TEXT
      )
    ''');

    await db.insert('users', {
      'username': 'admin',
      'password': 'admin123',
      'role': 'Administrateur',
      'fullName': 'Admin PharmaOne',
      'createdAt': DateTime.now().toIso8601String(),
    });

    await db.insert('users', {
      'username': 'pharmacien',
      'password': 'pharma123',
      'role': 'Pharmacien',
      'fullName': 'Dr. Jean',
      'createdAt': DateTime.now().toIso8601String(),
    });

    await db.insert('users', {
      'username': 'caissier',
      'password': 'caisse123',
      'role': 'Caissier',
      'fullName': 'M. Paul',
      'createdAt': DateTime.now().toIso8601String(),
    });

    await db.insert('pharmacy_settings', {
      'name': 'PharmaOne',
      'address': 'Kinshasa, RDC',
      'phone': '+243 999 000 000',
      'currency': 'CDF',
      'taxRate': 16.0,
      'logoPath': '',
    });

    await db.insert('suppliers', {
      'name': 'Fournisseur Central',
      'phone': '+243 999 111 111',
      'address': 'Gombe',
      'note': 'Fournisseur principal',
      'createdAt': DateTime.now().toIso8601String(),
    });

    await db.insert('products', {
      'name': 'Paracetamol 500mg',
      'category': 'Antalgique',
      'barcode': '1234567890123',
      'purchasePrice': 250.0,
      'salePrice': 350.0,
      'quantity': 120,
      'manufactureDate': '2025-01-01',
      'expiryDate': '2027-01-01',
      'supplier': 'Fournisseur Central',
      'createdAt': DateTime.now().toIso8601String(),
    });

    await db.insert('products', {
      'name': 'Amoxicilline 250mg',
      'category': 'Antibiotique',
      'barcode': '1234567890124',
      'purchasePrice': 500.0,
      'salePrice': 700.0,
      'quantity': 15,
      'manufactureDate': '2024-01-01',
      'expiryDate': '2026-07-01',
      'supplier': 'Fournisseur Central',
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> backupDatabase(String path) async {
    final db = await database;
    final source = File(db.path);
    if (!await source.exists()) {
      throw Exception('Base de données introuvable pour la sauvegarde');
    }
    await source.copy(path);
  }

  Future<void> restoreDatabase(String path) async {
    final db = await database;
    await db.close();
    _database = null;
    final backupFile = File(path);
    if (!await backupFile.exists()) {
      throw Exception('Fichier de sauvegarde introuvable');
    }
    final dbPath = await getDatabasesPath();
    final targetPath = join(dbPath, 'pharmaone.db');
    await backupFile.copy(targetPath);
    _database = await _initDatabase();
  }
}
