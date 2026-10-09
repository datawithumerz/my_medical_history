import 'package:flutter_test/flutter_test.dart';
import 'package:my_medical_history/domain/records.dart';
import 'package:my_medical_history/state/medical_store.dart';

import 'support/memory_repository.dart';

void main() {
  test(
    'failed writes leave visible records unchanged and allow retry',
    () async {
      final repository = MemoryRepository();
      final store = MedicalStore(repository);
      await store.load();
      const doctor = Doctor(id: 'doctor', name: 'Doctor');
      repository.failWrites = true;
      await expectLater(store.saveDoctor(doctor), throwsStateError);
      expect(store.doctors, isEmpty);
      expect(store.busy, isFalse);
      repository.failWrites = false;
      await store.saveDoctor(doctor);
      final visit = Visit(
        id: 'visit',
        doctorId: doctor.id,
        date: DateTime(2026),
        reason: 'Reason',
      );
      await store.saveVisit(visit);
      repository.failWrites = true;
      await expectLater(store.deleteVisit(visit.id), throwsStateError);
      expect(store.visits.single.id, visit.id);
      expect(() => store.deleteDoctor(doctor.id), throwsStateError);
      store.dispose();
    },
  );

  test(
    'visits round-trip all optional data and counts reflect saved data',
    () async {
      final store = MedicalStore(MemoryRepository());
      await store.saveDoctor(const Doctor(id: 'd', name: 'Doctor'));
      final original = Visit(
        id: 'a',
        doctorId: 'd',
        date: DateTime(2026, 10, 9, 11, 20),
        reason: 'Reason',
        diagnosis: 'Diagnosis',
        notes: 'Notes\nSecond line',
        facility: 'Clinic',
        medicines: const [Medicine(name: 'Medicine', instructions: 'Dose')],
        tests: const [MedicalTest(name: 'Test', result: 'Result')],
      );
      expect(Visit.fromMap(original.toMap()).toMap(), original.toMap());
      await store.saveVisit(original);
      await store.saveVisit(
        Visit(
          id: 'b',
          doctorId: 'd',
          date: DateTime(2025),
          reason: 'Another visit',
          medicines: const [Medicine(name: ' medicine ')],
        ),
      );
      expect(store.visits.map((v) => v.id), ['a', 'b']);
      expect(store.medicineCount, 1);
      expect(store.testCount, 1);
      await store.deleteVisit('a');
      expect(store.testCount, 0);
      expect(store.visitsFor('d').single.id, 'b');
      expect(store.accountSync.isConnected, isFalse);
      await expectLater(store.accountSync.sync(), throwsStateError);
      await expectLater(store.driveBackup.backUp(), throwsStateError);
      await expectLater(store.driveBackup.restore(), throwsStateError);
      store.dispose();
    },
  );
}
