import 'dart:convert';

class Doctor {
  const Doctor({
    required this.id,
    required this.name,
    this.specialty = '',
    this.facility = '',
    this.phone = '',
  });
  final String id;
  final String name;
  final String specialty;
  final String facility;
  final String phone;

  Map<String, Object?> toMap() => {
    'id': id,
    'name': name,
    'specialty': specialty,
    'facility': facility,
    'phone': phone,
  };
  factory Doctor.fromMap(Map<String, Object?> map) => Doctor(
    id: map['id'] as String,
    name: map['name'] as String,
    specialty: map['specialty'] as String,
    facility: map['facility'] as String,
    phone: map['phone'] as String,
  );
}

class Medicine {
  const Medicine({required this.name, this.instructions = ''});
  final String name;
  final String instructions;
  Map<String, Object?> toMap() => {'name': name, 'instructions': instructions};
  factory Medicine.fromMap(Map<String, dynamic> map) => Medicine(
    name: map['name'] as String,
    instructions: map['instructions'] as String,
  );
}

class MedicalTest {
  const MedicalTest({this.id = '', required this.name, this.result = ''});
  final String id;
  final String name;
  final String result;
  Map<String, Object?> toMap() => {'id': id, 'name': name, 'result': result};
  factory MedicalTest.fromMap(Map<String, dynamic> map) => MedicalTest(
    id: map['id'] as String? ?? '',
    name: map['name'] as String,
    result: map['result'] as String,
  );
}

class Visit {
  Visit({
    required this.id,
    required this.doctorId,
    required this.date,
    required this.reason,
    this.diagnosis = '',
    this.notes = '',
    this.facility = '',
    this.followUp,
    List<Medicine> medicines = const [],
    List<MedicalTest> tests = const [],
  }) : medicines = List.unmodifiable(medicines),
       tests = List.unmodifiable(
         tests.indexed.map(
           (entry) => entry.$2.id.isEmpty
               ? MedicalTest(
                   id: 'legacy:$id:${entry.$1}',
                   name: entry.$2.name,
                   result: entry.$2.result,
                 )
               : entry.$2,
         ),
       );
  final String id;
  final String doctorId;
  final DateTime date;
  final String reason;
  final String diagnosis;
  final DateTime? followUp;
  final String notes;
  // Capture the facility at the visit, so later doctor edits do not rewrite it.
  final String facility;
  final List<Medicine> medicines;
  final List<MedicalTest> tests;

  Map<String, Object?> toMap() => {
    'id': id,
    'doctor_id': doctorId,
    'date': date.toIso8601String(),
    'reason': reason,
    'diagnosis': diagnosis,
    'notes': notes,
    'facility': facility,
    'follow_up': followUp?.toIso8601String(),
    'medicines': jsonEncode(medicines.map((m) => m.toMap()).toList()),
    'tests': jsonEncode(tests.map((t) => t.toMap()).toList()),
  };
  factory Visit.fromMap(Map<String, Object?> map) => Visit(
    id: map['id'] as String,
    doctorId: map['doctor_id'] as String,
    date: DateTime.parse(map['date'] as String),
    reason: map['reason'] as String,
    diagnosis: map['diagnosis'] as String,
    notes: map['notes'] as String,
    facility: map['facility'] as String,
    followUp: map['follow_up'] == null
        ? null
        : DateTime.parse(map['follow_up'] as String),
    medicines: (jsonDecode(map['medicines'] as String) as List)
        .map((m) => Medicine.fromMap(m as Map<String, dynamic>))
        .toList(),
    tests: (jsonDecode(map['tests'] as String) as List)
        .map((t) => MedicalTest.fromMap(t as Map<String, dynamic>))
        .toList(),
  );
}

class Attachment {
  const Attachment({
    required this.id,
    required this.visitId,
    this.testId,
    required this.name,
    required this.storedName,
    required this.mimeType,
    required this.size,
    required this.createdAt,
  });
  final String id;
  final String visitId;
  final String? testId;
  final String name;
  // Relative generated filename, never the original picker path.
  final String storedName;
  final String mimeType;
  final int size;
  final DateTime createdAt;
  bool get isImage => mimeType.startsWith('image/');
  Attachment atVisit() => Attachment(
    id: id,
    visitId: visitId,
    name: name,
    storedName: storedName,
    mimeType: mimeType,
    size: size,
    createdAt: createdAt,
  );
  Map<String, Object?> toMap() => {
    'id': id,
    'visit_id': visitId,
    'test_id': testId,
    'name': name,
    'stored_name': storedName,
    'mime_type': mimeType,
    'size': size,
    'created_at': createdAt.toIso8601String(),
  };
  factory Attachment.fromMap(Map<String, Object?> map) => Attachment(
    id: map['id'] as String,
    visitId: map['visit_id'] as String,
    testId: map['test_id'] as String?,
    name: map['name'] as String,
    storedName: map['stored_name'] as String,
    mimeType: map['mime_type'] as String,
    size: map['size'] as int,
    createdAt: DateTime.parse(map['created_at'] as String),
  );
}
