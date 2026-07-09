import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import '../models/transaction.dart';

class DbHelper {
  DbHelper._internal();
  static final DbHelper instance = DbHelper._internal();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _keyName = 'db_passphrase_v1';

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  // Generates a random 256-bit passphrase on first run and stores it in the
  // Android Keystore (hardware-backed on most devices). The passphrase
  // itself never touches disk in plaintext and is never logged.
  Future<String> _getOrCreatePassphrase() async {
    final existing = await _storage.read(key: _keyName);
    if (existing != null) return existing;
    final rand = Random.secure();
    final bytes = List<int>.generate(32, (_) => rand.nextInt(256));
    final passphrase = base64UrlEncode(bytes);
    await _storage.write(key: _keyName, value: passphrase);
    return passphrase;
  }

  Future<Database> _open() async {
    final passphrase = await _getOrCreatePassphrase();
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = join(dir.path, 'expense_tracker_secure.db');

    return openDatabase(
      dbPath,
      password: passphrase,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions (
            id TEXT PRIMARY KEY,
            amount REAL NOT NULL,
            type TEXT NOT NULL,
            category TEXT NOT NULL,
            note TEXT,
            source TEXT NOT NULL,
            date TEXT NOT NULL,
            balanceAfter REAL
          )
        ''');
        await db.execute('''
          CREATE TABLE investments (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            kind TEXT NOT NULL,
            invested REAL NOT NULL,
            currentValue REAL NOT NULL,
            lastUpdated TEXT NOT NULL
          )
        ''');
        // Raw inbound SMS text is never stored — only parsed, structured
        // fields above. This table intentionally does not exist.
      },
    );
  }

  Future<void> insertTransaction(Transaction t) async {
    final database = await db;
    await database.insert(
      'transactions',
      t.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Transaction>> getTransactions({int? limit}) async {
    final database = await db;
    final rows = await database.query(
      'transactions',
      orderBy: 'date DESC',
      limit: limit,
    );
    return rows.map(Transaction.fromMap).toList();
  }

  Future<List<Transaction>> getTransactionsBetween(
      DateTime start, DateTime end) async {
    final database = await db;
    final rows = await database.query(
      'transactions',
      where: 'date >= ? AND date <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    return rows.map(Transaction.fromMap).toList();
  }

  Future<void> deleteTransaction(String id) async {
    final database = await db;
    await database.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> upsertInvestment(Investment inv) async {
    final database = await db;
    await database.insert(
      'investments',
      inv.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Investment>> getInvestments() async {
    final database = await db;
    final rows = await database.query('investments', orderBy: 'name ASC');
    return rows.map(Investment.fromMap).toList();
  }

  Future<void> deleteInvestment(String id) async {
    final database = await db;
    await database.delete('investments', where: 'id = ?', whereArgs: [id]);
  }
}
