import '../domain/records.dart';

class MedicalRecords {
  const MedicalRecords(
    this.doctors,
    this.visits, [
    this.attachments = const [],
  ]);
  final List<Doctor> doctors;
  final List<Visit> visits;
  final List<Attachment> attachments;
}

/// Local persistence boundary. Cloud adapters must never replace local saves.
abstract interface class MedicalRepository {
  Future<MedicalRecords> load();
  Future<void> saveDoctor(Doctor doctor);
  Future<void> saveVisit(Visit visit);
  Future<void> deleteVisit(String id);
  Future<void> deleteDoctor(String id);
  Future<void> saveAttachment(Attachment attachment);
  Future<void> deleteAttachment(String id);
  Future<List<String>> pendingFileDeletions();
  Future<void> completeFileDeletion(String storedName);
  Future<void> close();
}
