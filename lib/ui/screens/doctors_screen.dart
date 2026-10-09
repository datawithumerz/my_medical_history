import 'package:flutter/material.dart';

import '../../state/medical_store.dart';
import '../actions.dart';
import '../widgets.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key, required this.store});
  final MedicalStore store;
  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  final _search = TextEditingController();
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doctors = widget.store.doctors
        .where(
          (d) => '${d.name} ${d.specialty} ${d.facility}'
              .toLowerCase()
              .contains(_search.text.trim().toLowerCase()),
        )
        .toList();
    return PageBody(
      children: [
        JournalHeading(
          'Doctors',
          action: FilledButton.icon(
            key: const Key('addDoctor'),
            onPressed: () => addDoctor(context, widget.store),
            icon: const Icon(Icons.add),
            label: const Text('Add doctor'),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('doctorSearch'),
          controller: _search,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            labelText: 'Search doctors',
            hintText: 'Name, specialty or clinic',
          ),
        ),
        const SizedBox(height: 12),
        Text(
          counted(doctors.length, 'doctor'),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (doctors.isEmpty)
          EmptyState(
            icon: Icons.people_outline,
            title: widget.store.doctors.isEmpty
                ? 'Your care team'
                : 'No matching doctors',
            message: widget.store.doctors.isEmpty
                ? 'Add a doctor once, then keep a separate record for each visit.'
                : 'Try another name, specialty or clinic.',
          )
        else
          ...doctors.map(
            (d) => DoctorCard(
              doctor: d,
              visitCount: widget.store.visitsFor(d.id).length,
              onOpen: () => openDoctor(context, widget.store, d.id),
            ),
          ),
      ],
    );
  }
}
