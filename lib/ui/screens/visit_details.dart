import 'package:flutter/material.dart';

import '../../state/medical_store.dart';
import '../actions.dart';
import '../forms/visit_form.dart';
import '../theme.dart';
import '../widgets.dart';
import '../attachments.dart';

class VisitDetails extends StatelessWidget {
  const VisitDetails({super.key, required this.store, required this.visitId});
  final MedicalStore store;
  final String visitId;
  Future<void> _delete(BuildContext context) async {
    if (!await confirmAction(
      context,
      title: 'Delete this visit?',
      message: 'This permanently removes this visit, its medicines, tests and attached files from this device. Other visits and the doctor will be kept.',
      action: 'Delete visit',
    )) {
      return;
    }
    try {
      await store.deleteVisit(visitId);
      if (context.mounted) {
        Navigator.pop(context);
        showMessage(context, 'Visit deleted');
      }
    } catch (_) {
      if (context.mounted) {
        showMessage(context, 'Could not delete the visit. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      final visit = store.visit(visitId);
      if (visit == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Visit details')),
          body: const Center(child: Text('This visit has been removed.')),
        );
      }
      final doctor = store.doctor(visit.doctorId)!;
      return Scaffold(
        appBar: AppBar(
          title: const Text('Visit details'),
          actions: [
            IconButton(
              key: const Key('editVisit'),
              tooltip: 'Edit visit',
              onPressed: store.busy
                  ? null
                  : () async {
                      final id = await Navigator.push<String>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VisitForm(store: store, visit: visit),
                        ),
                      );
                      if (id != null && context.mounted) {
                        showMessage(context, 'Visit updated on this device');
                      }
                    },
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              key: const Key('deleteVisit'),
              tooltip: 'Delete visit',
              onPressed: store.busy ? null : () => _delete(context),
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
        body: PageBody(
          children: [
            Text(
              dateTimeLabel(context, visit.date),
              style: const TextStyle(color: Color(0xFF43474E)),
            ),
            const SizedBox(height: 12),
            Text(
              visit.reason,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: InfoPill(
                'Saved on this device',
                icon: Icons.phone_android,
              ),
            ),
            const SectionTitle('Consultation overview'),
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: const CircleAvatar(
                  backgroundColor: mutedSurface,
                  child: Icon(Icons.person_outline, color: journalTeal),
                ),
                title: Text(doctor.name),
                subtitle: Text(
                  doctor.specialty.isEmpty
                      ? 'View doctor profile'
                      : doctor.specialty,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => openDoctor(context, store, doctor.id),
              ),
            ),
            if (visit.facility.isNotEmpty) ...[
              const SizedBox(height: 12),
              Panel(
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_hospital_outlined,
                      color: journalTeal,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(visit.facility)),
                  ],
                ),
              ),
            ],
            const SectionTitle('Diagnosis'),
            Panel(
              child: SelectableText(
                visit.diagnosis.isEmpty
                    ? 'No diagnosis recorded for this visit.'
                    : visit.diagnosis,
              ),
            ),
            const SectionTitle('Notes & personal log'),
            Panel(
              child: SelectableText(
                visit.notes.isEmpty
                    ? 'No notes recorded for this visit.'
                    : visit.notes,
              ),
            ),
            SectionTitle('Medicines (${visit.medicines.length})'),
            if (visit.medicines.isEmpty)
              const Panel(child: Text('No medicines recorded for this visit.'))
            else
              ...visit.medicines.map(
                (medicine) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Panel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medicine.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          medicine.instructions.isEmpty
                              ? 'No dose or instructions recorded.'
                              : medicine.instructions,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            SectionTitle('Tests (${visit.tests.length})'),
            if (visit.tests.isEmpty)
              const Panel(child: Text('No tests recorded for this visit.'))
            else
              ...visit.tests.map(
                (test) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Panel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          test.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          test.result.isEmpty
                              ? 'No result recorded.'
                              : test.result,
                        ),
                        TextButton.icon(
                          onPressed: store.busy
                              ? null
                              : () => addAttachment(
                                  context,
                                  store,
                                  visitId: visit.id,
                                  testId: test.id,
                                ),
                          icon: const Icon(Icons.attach_file),
                          label: const Text('Attach file to this test'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            SectionTitle(
              'Attachments (${store.attachmentsFor(visit.id).length})',
              action: IconButton(
                key: const Key('visitAddAttachment'),
                tooltip: 'Add attachment',
                onPressed: store.busy
                    ? null
                    : () => addAttachment(context, store, visitId: visit.id),
                icon: const Icon(Icons.attach_file),
              ),
            ),
            if (store.attachmentsFor(visit.id).isEmpty)
              const Text('No files attached to this visit.')
            else
              ...store
                  .attachmentsFor(visit.id)
                  .map(
                    (a) => AttachmentRow(
                      key: ValueKey(a.id),
                      store: store,
                      attachment: a,
                    ),
                  ),
            if (visit.followUp != null) ...[
              const SectionTitle('Recorded follow-up'),
              Text(dateLabel(visit.followUp!)),
            ],
            const SizedBox(height: 20),
            const Text(
              'These are your recorded details. Account sync and Google Drive backup are not connected.',
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    },
  );
}
