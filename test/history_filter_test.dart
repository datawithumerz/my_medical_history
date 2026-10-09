import 'package:flutter_test/flutter_test.dart';
import 'package:my_medical_history/domain/history_filter.dart';
import 'package:my_medical_history/domain/records.dart';

void main() {
  test('date boundaries are inclusive and filters combine without changing clinical text', () {
    final visit = Visit(
      id: 'v',
      doctorId: 'd',
      date: DateTime(2026, 10, 9, 23, 59),
      reason: ' Exact text ',
      notes: 'Important\nnote',
      medicines: const [Medicine(name: 'A medicine')],
      tests: const [MedicalTest(name: 'A test')],
    );
    const doctor = Doctor(id: 'd', name: 'Doctor Name');
    final filter = HistoryFilter(
      doctorId: 'd',
      from: DateTime(2026, 10, 9),
      to: DateTime(2026, 10, 9),
      withMedicines: true,
      withTests: true,
    );
    expect(filter.matches(visit, doctor, ' DOCTOR name '), isTrue);
    expect(filter.matches(visit, doctor, 'medicine'), isTrue);
    expect(filter.matches(visit, doctor, 'missing'), isFalse);
    expect(
      const HistoryFilter(doctorId: 'other').matches(visit, doctor, ''),
      isFalse,
    );
    expect(
      HistoryFilter(to: DateTime(2026, 10, 8)).matches(visit, doctor, ''),
      isFalse,
    );
    expect(
      HistoryFilter(from: DateTime(2026, 10, 10)).matches(visit, doctor, ''),
      isFalse,
    );
    expect(visit.reason, ' Exact text ');
  });
}
