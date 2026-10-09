import 'package:flutter/material.dart';

import '../../state/medical_store.dart';
import '../actions.dart';
import '../theme.dart';
import '../widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.store, required this.onTab});
  final MedicalStore store;
  final ValueChanged<int> onTab;
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final followUps =
        store.visits
            .where((v) => v.followUp != null && !v.followUp!.isBefore(today))
            .toList()
          ..sort((a, b) => a.followUp!.compareTo(b.followUp!));
    final greeting = now.hour < 12
        ? 'Good morning'
        : now.hour < 18
        ? 'Good afternoon'
        : 'Good evening';
    return PageBody(
      children: [
        Text(dateLabel(now), style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 6),
        Text(greeting, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 18),
        FilledButton.icon(
          key: const Key('homeAddVisit'),
          onPressed: () => addVisit(context, store),
          icon: const Icon(Icons.add),
          label: const Text('Add visit'),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 14,
          runSpacing: 0,
          children: [
            TextButton(
              onPressed: () => onTab(1),
              child: Text(counted(store.doctors.length, 'doctor')),
            ),
            TextButton(
              onPressed: () => onTab(2),
              child: Text(counted(store.visits.length, 'visit')),
            ),
            TextButton(
              onPressed: () => onTab(2),
              child: Text('${store.medicineCount} medicine names'),
            ),
            TextButton(
              onPressed: () => onTab(3),
              child: Text(counted(store.testCount, 'test')),
            ),
          ],
        ),
        const Divider(),
        if (followUps.isNotEmpty) ...[
          const SectionTitle('Next recorded follow-up'),
          InkWell(
            onTap: () => openVisit(context, store, followUps.first.id),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: mutedSurface,
                border: Border(left: BorderSide(color: journalTeal, width: 3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateLabel(followUps.first.followUp!),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(store.doctor(followUps.first.doctorId)!.name),
                  const SizedBox(height: 4),
                  const Text(
                    'Date recorded on your visit',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
        SectionTitle(
          'Latest visit',
          action: TextButton(
            onPressed: () => onTab(2),
            child: const Text('View history'),
          ),
        ),
        if (store.visits.isEmpty)
          EmptyState(
            icon: Icons.menu_book_outlined,
            title: 'Begin your medical journal',
            message: 'Keep each visit and its documents together. Start by adding your doctor.',
            action: store.doctors.isEmpty
                ? OutlinedButton.icon(
                    key: const Key('homeAddDoctor'),
                    onPressed: () => addDoctor(context, store),
                    icon: const Icon(Icons.person_add_alt),
                    label: const Text('Add your first doctor'),
                  )
                : null,
          )
        else
          VisitCard(
            visit: store.visits.first,
            doctorName: store.doctor(store.visits.first.doctorId)!.name,
            attachmentCount: store.attachmentsFor(store.visits.first.id).length,
            onOpen: () => openVisit(context, store, store.visits.first.id),
          ),
        if (store.visits.length > 1) ...[
          const SectionTitle('Earlier entries'),
          ...store.visits
              .skip(1)
              .take(2)
              .map(
                (v) => VisitCard(
                  visit: v,
                  doctorName: store.doctor(v.doctorId)!.name,
                  attachmentCount: store.attachmentsFor(v.id).length,
                  onOpen: () => openVisit(context, store, v.id),
                ),
              ),
        ],
        if (store.doctors.isNotEmpty) ...[
          SectionTitle(
            'Your doctors',
            action: TextButton(
              onPressed: () => onTab(1),
              child: const Text('View all'),
            ),
          ),
          ...store.doctors
              .take(2)
              .map(
                (d) => DoctorCard(
                  doctor: d,
                  visitCount: store.visitsFor(d.id).length,
                  onOpen: () => openDoctor(context, store, d.id),
                ),
              ),
        ],
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () => onTab(4),
          icon: const Icon(Icons.phone_android, size: 16),
          label: const Text(
            'On this device · Cloud not connected',
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}
