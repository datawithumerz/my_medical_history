import 'package:flutter/material.dart';

import '../../state/medical_store.dart';
import '../actions.dart';
import '../forms/doctor_form.dart';
import '../theme.dart';
import '../widgets.dart';

class DoctorDetails extends StatelessWidget {
  const DoctorDetails({super.key, required this.store, required this.doctorId});
  final MedicalStore store;
  final String doctorId;
  Future<void> _delete(BuildContext context) async {
    if (store.visitsFor(doctorId).isNotEmpty) {
      showMessage(
        context,
        'This doctor has saved visits. Delete those visits first to remove the doctor.',
      );
      return;
    }
    if (!await confirmAction(
      context,
      title: 'Delete doctor?',
      message:
          'This removes the doctor from this device. This cannot be undone.',
      action: 'Delete doctor',
    )) {
      return;
    }
    try {
      await store.deleteDoctor(doctorId);
      if (context.mounted) {
        Navigator.pop(context);
        showMessage(context, 'Doctor deleted');
      }
    } catch (_) {
      if (context.mounted) {
        showMessage(context, 'Could not delete this doctor. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      final doctor = store.doctor(doctorId);
      if (doctor == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Doctor')),
          body: const Center(child: Text('This doctor has been removed.')),
        );
      }
      final visits = store.visitsFor(doctorId);
      return Scaffold(
        appBar: AppBar(
          title: const Text('Doctor details'),
          actions: [
            IconButton(
              tooltip: 'Edit doctor',
              onPressed: store.busy
                  ? null
                  : () async {
                      final id = await Navigator.push<String>(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              DoctorForm(store: store, doctor: doctor),
                        ),
                      );
                      if (id != null && context.mounted) {
                        showMessage(context, 'Doctor updated on this device');
                      }
                    },
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
        ),
        body: PageBody(
          children: [
            Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: mutedSurface,
                        child: Icon(
                          Icons.person_outline,
                          color: journalTeal,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctor.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            if (doctor.specialty.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                doctor.specialty,
                                style: const TextStyle(color: journalTeal),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (doctor.facility.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Text(doctor.facility),
                  ],
                  if (doctor.phone.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SelectableText('Phone: ${doctor.phone}'),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                InfoPill(
                  counted(visits.length, 'visit'),
                  icon: Icons.event_note_outlined,
                ),
                if (visits.isNotEmpty)
                  InfoPill('Latest: ${dateLabel(visits.first.date)}'),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              key: const Key('doctorAddVisit'),
              onPressed: () => addVisit(context, store, doctorId: doctorId),
              icon: const Icon(Icons.add),
              label: const Text('Add visit to this doctor'),
            ),
            const SectionTitle('Visit history'),
            if (visits.isEmpty)
              const EmptyState(
                icon: Icons.event_note_outlined,
                title: 'Your first visit starts here',
                message: 'Add a visit to record the reason, advice, medicines and tests in one place.',
              )
            else
              ...visits.map(
                (v) => VisitCard(
                  visit: v,
                  doctorName: doctor.name,
                  onOpen: () => openVisit(context, store, v.id),
                ),
              ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: store.busy ? null : () => _delete(context),
              icon: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              label: Text(
                'Delete doctor',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        ),
      );
    },
  );
}
