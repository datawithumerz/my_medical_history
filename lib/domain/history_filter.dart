import 'records.dart';

class HistoryFilter {
  const HistoryFilter({
    this.doctorId,
    this.from,
    this.to,
    this.withMedicines = false,
    this.withTests = false,
  });
  final String? doctorId;
  final DateTime? from;
  final DateTime? to;
  final bool withMedicines;
  final bool withTests;
  int get count =>
      (doctorId == null ? 0 : 1) +
      (from == null && to == null ? 0 : 1) +
      (withMedicines ? 1 : 0) +
      (withTests ? 1 : 0);
  bool matches(Visit visit, Doctor? doctor, String query) {
    final day = DateTime(visit.date.year, visit.date.month, visit.date.day);
    final text = [
      visit.reason,
      visit.diagnosis,
      visit.notes,
      visit.facility,
      doctor?.name ?? '',
      ...visit.medicines.expand((m) => [m.name, m.instructions]),
      ...visit.tests.expand((t) => [t.name, t.result]),
    ].join(' ').toLowerCase();
    return (doctorId == null || doctorId == visit.doctorId) &&
        (from == null ||
            !day.isBefore(DateTime(from!.year, from!.month, from!.day))) &&
        (to == null || !day.isAfter(DateTime(to!.year, to!.month, to!.day))) &&
        (!withMedicines || visit.medicines.isNotEmpty) &&
        (!withTests || visit.tests.isNotEmpty) &&
        text.contains(query.trim().toLowerCase());
  }
}
