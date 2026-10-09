import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_medical_history/data/sqlite_medical_repository.dart';
import 'package:my_medical_history/domain/records.dart';
import 'package:my_medical_history/services/attachment_files.dart';
import 'package:my_medical_history/state/medical_store.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'support/memory_repository.dart';

final tinyPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jRZkAAAAASUVORK5CYII=',
);

void main() {
  sqfliteFfiInit();
  test('v1 migration preserves raw records; files survive source deletion and fresh process', () async {
    final temporary = await Directory.systemTemp.createTemp(
      'journal_migration_',
    );
    final dbPath = p.join(temporary.path, 'old.db');
    final fileRoot = Directory(p.join(temporary.path, 'files'));
    final old = await databaseFactoryFfi.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, _) async {
          await db.execute(
            'CREATE TABLE doctors (id TEXT PRIMARY KEY, name TEXT NOT NULL, specialty TEXT NOT NULL, facility TEXT NOT NULL, phone TEXT NOT NULL)',
          );
          await db.execute(
            'CREATE TABLE visits (id TEXT PRIMARY KEY, doctor_id TEXT NOT NULL REFERENCES doctors(id) ON DELETE RESTRICT, date TEXT NOT NULL, reason TEXT NOT NULL, diagnosis TEXT NOT NULL, notes TEXT NOT NULL, facility TEXT NOT NULL, medicines TEXT NOT NULL, tests TEXT NOT NULL)',
          );
        },
      ),
    );
    const doctor = Doctor(id: 'existing-doctor', name: 'Existing doctor');
    final original = <String, Object?>{
      'id': 'first',
      'doctor_id': doctor.id,
      'date': '2026-09-09T10:20:00.000',
      'reason': '  Exact reason  ',
      'diagnosis': '  Recorded diagnosis\r\n',
      'notes': '  Keep\r\nthis text exactly — محفوظ  ',
      'facility': ' Original clinic ',
      'medicines':
          '[{"name":" Medicine ","instructions":"  Dose\\nInstructions  "}]',
      'tests': '[{"name":"  Test A  ","result":" Exact result "},{"name":"Test B","result":""}]',
    };
    final second = {...original, 'id': 'second', 'reason': 'Separate visit'};
    await old.insert('doctors', doctor.toMap());
    await old.insert('visits', original);
    await old.insert('visits', second);
    await old.close();
    var repository = await SqliteMedicalRepository.open(
      factory: databaseFactoryFfi,
      path: dbPath,
    );
    var store = MedicalStore(repository, files: AttachmentFiles(fileRoot));
    await store.load();
    final raw = await databaseFactoryFfi.openDatabase(dbPath);
    final unchanged = (await raw.query(
      'visits',
      where: 'id = ?',
      whereArgs: ['first'],
    )).single;
    for (final key in original.keys) {
      expect(unchanged[key], original[key], reason: 'Migration changed $key');
    }
    expect(unchanged['follow_up'], isNull);
    expect(store.visitsFor(doctor.id), hasLength(2));
    final first = store.visit('first')!;
    final secondBefore = store.visit('second')!.toMap();
    final source = File(p.join(temporary.path, 'picker-cache.png'));
    await source.writeAsBytes(tinyPng);
    await store.addAttachment(
      visitId: first.id,
      testId: first.tests.first.id,
      name: 'My scan.png',
      content: source.openRead(),
    );
    final image = store.attachments.single;
    await source.delete();
    expect(
      await (await store.files!.resolve(image.storedName)).readAsBytes(),
      tinyPng,
    );
    final pdfBytes = utf8.encode('%PDF-1.4\nTest fixture\n%%EOF');
    await store.addAttachment(
      visitId: 'second',
      name: 'Report.pdf',
      content: Stream.value(pdfBytes),
    );
    final pdf = store.attachments.first;
    expect(pdf.mimeType, 'application/pdf');
    await repository.close();
    store.dispose();
    final probe = await Process.run('dart', [
      'run',
      'test/support/sqlite_probe.dart',
      dbPath,
      fileRoot.path,
    ], runInShell: Platform.isWindows);
    expect(probe.exitCode, 0, reason: '${probe.stderr}');
    final external = jsonDecode(probe.stdout as String) as Map<String, dynamic>;
    expect(external['attachments'], hasLength(2));
    expect(external['fileBytes'][image.storedName], base64Encode(tinyPng));
    expect(external['fileBytes'][pdf.storedName], base64Encode(pdfBytes));
    repository = await SqliteMedicalRepository.open(
      factory: databaseFactoryFfi,
      path: dbPath,
    );
    store = MedicalStore(repository, files: AttachmentFiles(fileRoot));
    await store.load();
    expect(store.visit(first.id)!.tests.first.id, first.tests.first.id);
    // Rename a test and reorder it without changing its attachment identity.
    await store.saveVisit(
      Visit(
        id: first.id,
        doctorId: doctor.id,
        date: first.date,
        reason: first.reason,
        diagnosis: first.diagnosis,
        notes: first.notes,
        facility: first.facility,
        medicines: first.medicines,
        tests: [
          first.tests.last,
          MedicalTest(
            id: first.tests.first.id,
            name: 'Renamed test',
            result: first.tests.first.result,
          ),
        ],
        followUp: DateTime(2027, 1, 5),
      ),
    );
    expect(store.attachmentsFor(first.id).single.testId, first.tests.first.id);
    expect(store.visit('second')!.toMap(), secondBefore);
    // Removing a test keeps its file linked to the original visit.
    await store.saveVisit(
      Visit(
        id: first.id,
        doctorId: doctor.id,
        date: first.date,
        reason: first.reason,
        diagnosis: first.diagnosis,
        notes: first.notes,
        facility: first.facility,
        medicines: first.medicines,
        tests: [first.tests.last],
        followUp: DateTime(2027, 1, 5),
      ),
    );
    expect(store.attachmentsFor(first.id).single.testId, isNull);
    await store.load();
    expect(store.attachmentsFor(first.id).single.testId, isNull);
    expect(store.visit(first.id)!.notes, original['notes']);
    expect(store.visit(first.id)!.followUp, DateTime(2027, 1, 5));
    await store.deleteVisit('second');
    expect(await store.files!.file(pdf.storedName).exists(), isFalse);
    expect(await store.files!.file(image.storedName).exists(), isTrue);
    expect(store.doctors.single.id, doctor.id);
    // A pending file deletion survives closing the app before unlinking.
    await repository.deleteAttachment(image.id);
    await repository.close();
    store.dispose();
    repository = await SqliteMedicalRepository.open(
      factory: databaseFactoryFfi,
      path: dbPath,
    );
    store = MedicalStore(repository, files: AttachmentFiles(fileRoot));
    await store.load();
    expect(store.attachments, isEmpty);
    expect(await fileRoot.list().toList(), isEmpty);
    await repository.close();
    store.dispose();
    await databaseFactoryFfi.deleteDatabase(dbPath);
    await fileRoot.delete();
    await temporary.delete();
  }, timeout: const Timeout(Duration(minutes: 3)));

  test('failed imports roll back copies; size/type/path checks and missing-file errors are explicit', () async {
    final temporary = await Directory.systemTemp.createTemp('journal_files_');
    final files = AttachmentFiles(temporary);
    final repository = MemoryRepository();
    final store = MedicalStore(repository, files: files);
    await store.saveDoctor(const Doctor(id: 'd', name: 'Doctor'));
    await store.saveVisit(
      Visit(id: 'v', doctorId: 'd', date: DateTime(2026), reason: 'Visit'),
    );
    repository.failWrites = true;
    await expectLater(
      store.addAttachment(
        visitId: 'v',
        name: 'image.png',
        content: Stream.value(tinyPng),
      ),
      throwsStateError,
    );
    expect(store.attachments, isEmpty);
    expect(await temporary.list().toList(), isEmpty);
    expect(store.busy, isFalse);
    repository.failWrites = false;
    await expectLater(
      store.addAttachment(
        visitId: 'v',
        name: 'fake.pdf',
        content: Stream.value([1, 2, 3]),
      ),
      throwsA(isA<AttachmentException>()),
    );
    final chunk = List.filled(1024 * 1024, 0);
    await expectLater(
      files.import(
        MedicalStore.newId(),
        Stream.fromIterable(List.filled(26, chunk)),
      ),
      throwsA(isA<AttachmentException>()),
    );
    expect(await temporary.list().toList(), isEmpty);
    expect(
      () => files.file('../outside.pdf'),
      throwsA(isA<AttachmentException>()),
    );
    await store.addAttachment(
      visitId: 'v',
      name: 'Scan.png',
      content: Stream.value(tinyPng),
    );
    final a = store.attachments.single;
    await files.file(a.storedName).delete();
    await expectLater(
      files.resolve(a.storedName),
      throwsA(
        isA<AttachmentException>().having(
          (e) => e.message,
          'message',
          contains('File missing'),
        ),
      ),
    );
    await store.removeAttachment(a.id);
    expect(store.attachments, isEmpty);
    store.dispose();
    await temporary.delete();
  });
}
