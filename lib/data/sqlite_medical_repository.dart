import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../domain/records.dart';
import 'medical_repository.dart';

class SqliteMedicalRepository implements MedicalRepository {
  SqliteMedicalRepository._(this._database);
  final Database _database;
  static Future<SqliteMedicalRepository> open({
    DatabaseFactory? factory,
    String? path,
  }) async {
    final dbFactory = factory ?? databaseFactory;
    final dbPath =
        path ??
        p.join(await dbFactory.getDatabasesPath(), 'medical_history.db');
    final database = await dbFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 2,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: (db, version) async {
          await db.execute(
            'CREATE TABLE doctors (id TEXT PRIMARY KEY, name TEXT NOT NULL, specialty TEXT NOT NULL, facility TEXT NOT NULL, phone TEXT NOT NULL)',
          );
          await db.execute(
            'CREATE TABLE visits (id TEXT PRIMARY KEY, doctor_id TEXT NOT NULL REFERENCES doctors(id) ON DELETE RESTRICT, date TEXT NOT NULL, reason TEXT NOT NULL, diagnosis TEXT NOT NULL, notes TEXT NOT NULL, facility TEXT NOT NULL, medicines TEXT NOT NULL, tests TEXT NOT NULL)',
          );
          await db.execute(
            'CREATE INDEX visits_doctor_date ON visits(doctor_id, date DESC)',
          );
          await _addVersion2(db);
        },
        // Additive only: no rewriting or deleting existing clinical records.
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) await _addVersion2(db);
        },
      ),
    );
    return SqliteMedicalRepository._(database);
  }

  static Future<void> _addVersion2(Database db) async {
    await db.execute('ALTER TABLE visits ADD COLUMN follow_up TEXT');
    await db.execute(
      'CREATE TABLE attachments (id TEXT PRIMARY KEY, visit_id TEXT NOT NULL REFERENCES visits(id) ON DELETE CASCADE, test_id TEXT, name TEXT NOT NULL, stored_name TEXT NOT NULL UNIQUE, mime_type TEXT NOT NULL, size INTEGER NOT NULL, created_at TEXT NOT NULL)',
    );
    await db.execute('CREATE INDEX attachments_visit ON attachments(visit_id)');
    await db.execute(
      'CREATE TABLE file_deletions (stored_name TEXT PRIMARY KEY)',
    );
  }

  @override
  Future<MedicalRecords> load() => _database.transaction(
    (txn) async => MedicalRecords(
      (await txn.query(
        'doctors',
        orderBy: 'name COLLATE NOCASE',
      )).map(Doctor.fromMap).toList(),
      (await txn.query(
        'visits',
        orderBy: 'date DESC, id DESC',
      )).map(Visit.fromMap).toList(),
      (await txn.query(
        'attachments',
        orderBy: 'created_at DESC, id DESC',
      )).map(Attachment.fromMap).toList(),
    ),
  );
  Future<void> _upsert(
    Transaction txn,
    String table,
    String id,
    Map<String, Object?> values,
  ) async {
    final updated = await txn.update(
      table,
      values,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (updated == 0) await txn.insert(table, values);
  }

  @override
  Future<void> saveDoctor(Doctor doctor) => _database.transaction(
    (txn) => _upsert(txn, 'doctors', doctor.id, doctor.toMap()),
  );
  @override
  Future<void> saveVisit(Visit visit) => _database.transaction((txn) async {
    await _upsert(txn, 'visits', visit.id, visit.toMap());
    final ids = visit.tests.map((t) => t.id).toSet();
    final linked = await txn.query(
      'attachments',
      where: 'visit_id = ? AND test_id IS NOT NULL',
      whereArgs: [visit.id],
    );
    for (final row in linked) {
      if (!ids.contains(row['test_id'])) {
        // Removing a test retains its files on the same visit.
        await txn.update(
          'attachments',
          {'test_id': null},
          where: 'id = ?',
          whereArgs: [row['id']],
        );
      }
    }
  });
  Future<void> _queueFiles(
    Transaction txn,
    List<Map<String, Object?>> rows,
  ) async {
    for (final row in rows) {
      await txn.insert('file_deletions', {
        'stored_name': row['stored_name'],
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  @override
  Future<void> deleteVisit(String id) => _database.transaction((txn) async {
    await _queueFiles(
      txn,
      await txn.query('attachments', where: 'visit_id = ?', whereArgs: [id]),
    );
    await txn.delete('visits', where: 'id = ?', whereArgs: [id]);
  });
  @override
  Future<void> deleteDoctor(String id) async {
    await _database.delete('doctors', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> saveAttachment(Attachment attachment) => _database.transaction((
    txn,
  ) async {
    final rows = await txn.query(
      'visits',
      where: 'id = ?',
      whereArgs: [attachment.visitId],
    );
    if (rows.isEmpty) throw StateError('The linked visit no longer exists.');
    if (attachment.testId != null &&
        !Visit.fromMap(rows.single).tests
            .any((t) => t.id == attachment.testId)) {
      throw StateError('The linked test no longer exists.');
    }
    await txn.insert('attachments', attachment.toMap());
  });
  @override
  Future<void> deleteAttachment(String id) =>
      _database.transaction((txn) async {
        await _queueFiles(
          txn,
          await txn.query('attachments', where: 'id = ?', whereArgs: [id]),
        );
        await txn.delete('attachments', where: 'id = ?', whereArgs: [id]);
      });
  @override
  Future<List<String>> pendingFileDeletions() async =>
      (await _database.query('file_deletions'))
          .map((r) => r['stored_name'] as String)
          .toList();
  @override
  Future<void> completeFileDeletion(String storedName) async {
    await _database.delete(
      'file_deletions',
      where: 'stored_name = ?',
      whereArgs: [storedName],
    );
  }

  @override
  Future<void> close() => _database.close();
}
