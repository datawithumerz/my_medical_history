import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/medical_repository.dart';
import '../domain/records.dart';
import '../services/connections.dart';
import '../services/attachment_files.dart';

class MedicalStore extends ChangeNotifier {
  MedicalStore(
    this.repository, {
    this.files,
    this.accountSync = const UnconfiguredAccountSync(),
    this.driveBackup = const UnconfiguredDriveBackup(),
  });
  final MedicalRepository repository;
  final AttachmentFiles? files;
  final AccountSyncService accountSync;
  final DriveBackupService driveBackup;
  List<Doctor> _doctors = [];
  List<Visit> _visits = [];
  List<Attachment> _attachments = [];
  List<Attachment> get attachments => List.unmodifiable(_attachments);
  List<Attachment> attachmentsFor(String visitId, {String? testId}) =>
      _attachments
          .where(
            (a) =>
                a.visitId == visitId && (testId == null || a.testId == testId),
          )
          .toList();
  List<Doctor> get doctors => List.unmodifiable(_doctors);
  List<Visit> get visits => List.unmodifiable(_visits);
  bool busy = false;

  static String newId() {
    final random = Random.secure();
    return List.generate(
      16,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }

  Future<void> load() async {
    final records = await repository.load();
    _doctors = List.of(records.doctors);
    _visits = List.of(records.visits);
    _attachments = List.of(records.attachments);
    _sort();
    notifyListeners();
    await cleanRemovedFiles();
  }

  Doctor? doctor(String id) {
    for (final doctor in _doctors) {
      if (doctor.id == id) return doctor;
    }
    return null;
  }

  Visit? visit(String id) {
    for (final visit in _visits) {
      if (visit.id == id) return visit;
    }
    return null;
  }

  List<Visit> visitsFor(String id) =>
      _visits.where((v) => v.doctorId == id).toList();
  int get medicineCount => _visits
      .expand((v) => v.medicines)
      .map((m) => m.name.trim().toLowerCase())
      .toSet()
      .length;
  int get testCount => _visits.fold(0, (sum, v) => sum + v.tests.length);

  void _sort() {
    _doctors.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    _visits.sort((a, b) {
      final date = b.date.compareTo(a.date);
      return date != 0 ? date : b.id.compareTo(a.id);
    });
  }

  Future<void> _write(
    Future<void> Function() persist,
    VoidCallback apply,
  ) async {
    if (busy) {
      throw StateError('Another save is in progress. Please try again.');
    }
    busy = true;
    notifyListeners();
    try {
      await persist();
      apply();
      _sort();
      await cleanRemovedFiles();
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> saveDoctor(Doctor doctor) {
    if (doctor.name.trim().isEmpty) {
      throw ArgumentError('A doctor name is required.');
    }
    return _write(() => repository.saveDoctor(doctor), () {
      _doctors.removeWhere((d) => d.id == doctor.id);
      _doctors.add(doctor);
    });
  }

  Future<void> saveVisit(Visit visit) {
    if (doctor(visit.doctorId) == null || visit.reason.trim().isEmpty) {
      throw ArgumentError('Choose a doctor and enter a visit reason.');
    }
    return _write(() => repository.saveVisit(visit), () {
      _visits.removeWhere((v) => v.id == visit.id);
      _visits.add(visit);
      final testIds = visit.tests.map((t) => t.id).toSet();
      _attachments = _attachments
          .map(
            (a) =>
                a.visitId == visit.id &&
                    a.testId != null &&
                    !testIds.contains(a.testId)
                ? a.atVisit()
                : a,
          )
          .toList();
    });
  }

  Future<void> deleteVisit(String id) =>
      _write(() => repository.deleteVisit(id), () {
        _visits.removeWhere((v) => v.id == id);
        _attachments.removeWhere((a) => a.visitId == id);
      });
  Future<void> deleteDoctor(String id) {
    if (visitsFor(id).isNotEmpty) {
      throw StateError('Delete this doctor’s visits first.');
    }
    return _write(
      () => repository.deleteDoctor(id),
      () => _doctors.removeWhere((d) => d.id == id),
    );
  }

  Future<void> addAttachment({
    required String visitId,
    String? testId,
    required String name,
    required Stream<List<int>> content,
  }) async {
    final fileStore = files;
    if (fileStore == null) {
      throw const AttachmentException(
        'Attachment storage could not be opened. Please restart the app.',
      );
    }
    if (visit(visitId) == null) {
      throw const AttachmentException('Choose a saved visit first.');
    }
    Attachment? attachment;
    await _write(() async {
      final id = newId();
      final copied = await fileStore.import(id, content);
      attachment = Attachment(
        id: id,
        visitId: visitId,
        testId: testId,
        name: name,
        storedName: copied.name,
        mimeType: copied.mimeType,
        size: copied.size,
        createdAt: DateTime.now(),
      );
      try {
        await repository.saveAttachment(attachment!);
      } catch (_) {
        try {
          await fileStore.remove(copied.name);
        } catch (_) {
          /* Keep original error. */
        }
        rethrow;
      }
    }, () => _attachments.insert(0, attachment!));
  }

  Future<void> removeAttachment(String id) => _write(
    () => repository.deleteAttachment(id),
    () => _attachments.removeWhere((a) => a.id == id),
  );

  /// Durable deletion queue: a failed unlink is retried on the next write/start.
  Future<void> cleanRemovedFiles() async {
    if (files == null) return;
    try {
      for (final name in await repository.pendingFileDeletions()) {
        try {
          await files!.remove(name);
          await repository.completeFileDeletion(name);
        } catch (_) {
          /* Retain queue entry for a later retry. */
        }
      }
    } catch (_) {
      /* Record saving must not fail because cleanup was unavailable. */
    }
  }
}
