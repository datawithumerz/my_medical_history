import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_medical_history/data/sqlite_medical_repository.dart';
import 'package:my_medical_history/domain/records.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  test('SQLite commits survive process restart, edits, deletion and failed foreign keys', () async {
    final directory = await Directory.systemTemp.createTemp(
      'medical_history_test_',
    );
    final path = p.join(directory.path, 'records.db');
    var repository = await SqliteMedicalRepository.open(
      factory: databaseFactoryFfi,
      path: path,
    );
    try {
      final empty = await repository.load();
      expect(empty.doctors, isEmpty);
      expect(empty.visits, isEmpty);
      const doctor = Doctor(
        id: 'doctor',
        name: 'Recorded doctor',
        specialty: 'Specialty',
        facility: 'Original clinic',
      );
      await repository.saveDoctor(doctor);
      final first = Visit(
        id: 'visit1',
        doctorId: doctor.id,
        date: DateTime(2026, 10, 8, 11, 30),
        reason: 'First visit',
        diagnosis: 'Recorded diagnosis',
        notes: 'A note\nAnother line',
        facility: doctor.facility,
        medicines: const [
          Medicine(
            name: 'Recorded medicine',
            instructions: 'Recorded instructions',
          ),
        ],
        tests: const [
          MedicalTest(name: 'Recorded test', result: 'Recorded result'),
        ],
      );
      final second = Visit(
        id: 'visit2',
        doctorId: doctor.id,
        date: DateTime(2026, 10, 9),
        reason: 'Separate visit',
      );
      await repository.saveVisit(first);
      await repository.saveVisit(second);
      await expectLater(
        repository.deleteDoctor(doctor.id),
        throwsA(isA<DatabaseException>()),
      );
      await repository.close();

      Future<Map<String, dynamic>> probe() async {
        final result = await Process.run('dart', [
          'run',
          'test/support/sqlite_probe.dart',
          path,
        ], runInShell: Platform.isWindows);
        expect(result.exitCode, 0, reason: '${result.stderr}');
        return jsonDecode(result.stdout as String) as Map<String, dynamic>;
      }

      final external = await probe();
      expect(external['doctors'], [doctor.toMap()]);
      expect(external['visits'], [first.toMap(), second.toMap()]);

      repository = await SqliteMedicalRepository.open(
        factory: databaseFactoryFfi,
        path: path,
      );
      final reopened = await repository.load();
      expect(reopened.visits.first.toMap(), second.toMap());
      expect(reopened.visits.last.toMap(), first.toMap());
      await repository.saveDoctor(
        const Doctor(
          id: 'doctor',
          name: 'Edited doctor',
          facility: 'New clinic',
        ),
      );
      final edited = Visit(
        id: first.id,
        doctorId: doctor.id,
        date: first.date,
        reason: 'Edited first visit',
        notes: 'Edited notes',
        facility: first.facility,
      );
      await repository.saveVisit(edited);
      final updated = await repository.load();
      expect(updated.visits.first.toMap(), second.toMap());
      expect(updated.visits.last.toMap(), edited.toMap());
      expect(updated.visits.last.facility, 'Original clinic');
      await repository.deleteVisit(first.id);
      await repository.close();
      final afterDelete = await probe();
      expect(afterDelete['visits'], [second.toMap()]);
      expect((afterDelete['doctors'] as List).single['name'], 'Edited doctor');

      repository = await SqliteMedicalRepository.open(
        factory: databaseFactoryFfi,
        path: path,
      );
      await repository.deleteVisit(second.id);
      await repository.deleteDoctor(doctor.id);
      final cleared = await repository.load();
      expect(cleared.doctors, isEmpty);
      expect(cleared.visits, isEmpty);
    } finally {
      await repository.close();
      await databaseFactoryFfi.deleteDatabase(path);
      await directory.delete();
    }
  }, timeout: const Timeout(Duration(minutes: 2)));
}
