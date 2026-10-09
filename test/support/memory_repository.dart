import 'package:my_medical_history/data/medical_repository.dart';
import 'package:my_medical_history/domain/records.dart';

class MemoryRepository implements MedicalRepository {
  final doctors = <String, Doctor>{};
  final visits = <String, Visit>{};
  final attachments = <String, Attachment>{};
  final removedFiles = <String>[];
  bool failWrites = false;
  void _check() {
    if (failWrites) throw StateError('Disk is full');
  }

  @override
  Future<MedicalRecords> load() async => MedicalRecords(
    doctors.values.toList(),
    visits.values.toList(),
    attachments.values.toList(),
  );
  @override
  Future<void> saveDoctor(Doctor doctor) async {
    _check();
    doctors[doctor.id] = doctor;
  }

  @override
  Future<void> saveVisit(Visit visit) async {
    _check();
    visits[visit.id] = visit;
    final ids = visit.tests.map((t) => t.id).toSet();
    for (final a in attachments.values.toList()) {
      if (a.visitId == visit.id && a.testId != null && !ids.contains(a.testId)) {
        attachments[a.id] = a.atVisit();
      }
    }
  }

  @override
  Future<void> deleteDoctor(String id) async {
    _check();
    doctors.remove(id);
  }

  @override
  Future<void> deleteVisit(String id) async {
    _check();
    for (final a in attachments.values.where((a) => a.visitId == id).toList()) {
      await deleteAttachment(a.id);
    }
    visits.remove(id);
  }

  @override
  Future<void> close() async {}
  @override
  Future<void> saveAttachment(Attachment attachment) async {
    _check();
    attachments[attachment.id] = attachment;
  }

  @override
  Future<void> deleteAttachment(String id) async {
    _check();
    final a = attachments.remove(id);
    if (a != null) removedFiles.add(a.storedName);
  }

  @override
  Future<List<String>> pendingFileDeletions() async => List.of(removedFiles);
  @override
  Future<void> completeFileDeletion(String storedName) async {
    removedFiles.remove(storedName);
  }
}
