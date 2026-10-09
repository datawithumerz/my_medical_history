import 'package:flutter/material.dart';

import '../state/medical_store.dart';
import 'forms/doctor_form.dart';
import 'forms/visit_form.dart';
import 'screens/doctor_details.dart';
import 'screens/visit_details.dart';
import 'widgets.dart';

Future<void> addDoctor(BuildContext context, MedicalStore store) async {
  final id = await Navigator.push<String>(
    context,
    MaterialPageRoute(builder: (_) => DoctorForm(store: store)),
  );
  if (id != null && context.mounted) {
    showMessage(context, 'Doctor saved on this device');
    openDoctor(context, store, id);
  }
}

Future<void> addVisit(
  BuildContext context,
  MedicalStore store, {
  String? doctorId,
}) async {
  if (store.doctors.isEmpty) {
    final id = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => DoctorForm(store: store)),
    );
    if (id == null || !context.mounted) return;
    doctorId = id;
  }
  if (!context.mounted) return;
  final id = await Navigator.push<String>(
    context,
    MaterialPageRoute(
      builder: (_) => VisitForm(store: store, doctorId: doctorId),
    ),
  );
  if (id != null && context.mounted) {
    showMessage(context, 'Visit saved on this device');
    openVisit(context, store, id);
  }
}

void openDoctor(BuildContext context, MedicalStore store, String id) =>
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DoctorDetails(store: store, doctorId: id),
      ),
    );
void openVisit(BuildContext context, MedicalStore store, String id) =>
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VisitDetails(store: store, visitId: id),
      ),
    );
