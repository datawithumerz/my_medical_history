import 'package:flutter/material.dart';

import '../../domain/records.dart';
import '../../state/medical_store.dart';
import '../widgets.dart';

class VisitForm extends StatefulWidget {
  const VisitForm({super.key, required this.store, this.doctorId, this.visit});
  final MedicalStore store;
  final String? doctorId;
  final Visit? visit;
  @override
  State<VisitForm> createState() => _VisitFormState();
}

class _Entry {
  _Entry([String name = '', String detail = '', String? stableId])
    : name = TextEditingController(text: name),
      detail = TextEditingController(text: detail),
      id = stableId ?? MedicalStore.newId();
  final String id;
  final TextEditingController name;
  final TextEditingController detail;
  void dispose() {
    name.dispose();
    detail.dispose();
  }
}

class _VisitFormState extends State<VisitForm> {
  final _form = GlobalKey<FormState>();
  late String? _doctorId = widget.visit?.doctorId ?? widget.doctorId;
  late DateTime _date = widget.visit?.date ?? DateTime.now();
  late DateTime? _followUp = widget.visit?.followUp;
  late final _reason = TextEditingController(text: widget.visit?.reason);
  late final _diagnosis = TextEditingController(text: widget.visit?.diagnosis);
  late final _notes = TextEditingController(text: widget.visit?.notes);
  late final _facility = TextEditingController(
    text:
        widget.visit?.facility ??
        widget.store.doctor(_doctorId ?? '')?.facility,
  );
  late final List<_Entry> _medicines =
      widget.visit?.medicines
          .map((m) => _Entry(m.name, m.instructions))
          .toList() ??
      [];
  late final List<_Entry> _tests =
      widget.visit?.tests.map((t) => _Entry(t.name, t.result, t.id)).toList() ??
      [];
  final List<_Entry> _removed = [];
  bool _saving = false;
  bool _dirty = false;
  bool _canLeave = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_reason, _diagnosis, _notes, _facility]) {
      c.dispose();
    }
    for (final entry in [..._medicines, ..._tests, ..._removed]) {
      entry.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _date = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _date.hour,
        _date.minute,
      );
      _dirty = true;
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_date),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _date = DateTime(
        _date.year,
        _date.month,
        _date.day,
        picked.hour,
        picked.minute,
      );
      _dirty = true;
    });
  }

  Future<void> _save() async {
    final fieldsValid = _form.currentState!.validate();
    // ListView can unmount off-screen fields. Check the complete draft as well
    // as mounted FormFields so long forms cannot bypass required validation.
    final draftValid =
        widget.store.doctor(_doctorId ?? '') != null &&
        _reason.text.trim().isNotEmpty &&
        [
          ..._medicines,
          ..._tests,
        ].every((entry) => entry.name.text.trim().isNotEmpty);
    if (!fieldsValid || !draftValid) {
      setState(
        () => _error = 'Check the required fields above, including any medicine or test you added.',
      );
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final visit = Visit(
      id: widget.visit?.id ?? MedicalStore.newId(),
      doctorId: _doctorId!,
      date: _date,
      followUp: _followUp,
      reason: _reason.text,
      diagnosis: _diagnosis.text,
      notes: _notes.text,
      facility: _facility.text,
      medicines: _medicines
          .map((m) => Medicine(name: m.name.text, instructions: m.detail.text))
          .toList(),
      tests: _tests
          .map(
            (t) =>
                MedicalTest(id: t.id, name: t.name.text, result: t.detail.text),
          )
          .toList(),
    );
    try {
      await widget.store.saveVisit(visit);
      if (!mounted) return;
      setState(() {
        _canLeave = true;
        _saving = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context, visit.id);
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Could not save the visit. Your entries are still here. Please try again.';
        });
      }
    }
  }

  List<Widget> _entryFields(List<_Entry> entries, bool medicine) {
    final noun = medicine ? 'medicine' : 'test';
    return [
      for (final (index, entry) in entries.indexed)
        Padding(
          key: ObjectKey(entry),
          padding: const EdgeInsets.only(bottom: 12),
          child: Panel(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${medicine ? 'Medicine' : 'Test'} ${index + 1}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remove $noun ${index + 1}',
                      onPressed: _saving
                          ? null
                          : () => setState(() {
                              entries.remove(entry);
                              _removed.add(entry);
                              _dirty = true;
                            }),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  key: Key('${noun}Name$index'),
                  controller: entry.name,
                  enabled: !_saving,
                  maxLength: 200,
                  decoration: InputDecoration(
                    labelText: '${medicine ? 'Medicine' : 'Test'} name *',
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a name or remove this $noun'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: Key('${noun}Detail$index'),
                  controller: entry.detail,
                  enabled: !_saving,
                  minLines: 2,
                  maxLines: 4,
                  maxLength: 2000,
                  decoration: InputDecoration(
                    labelText: medicine
                        ? 'Dose & instructions (optional)'
                        : 'Result or notes (optional)',
                    hintText: medicine
                        ? 'Record the instructions you were given'
                        : 'Record a result if available',
                  ),
                ),
              ],
            ),
          ),
        ),
      OutlinedButton.icon(
        key: Key('add${medicine ? 'Medicine' : 'Test'}'),
        onPressed: _saving
            ? null
            : () => setState(() {
                entries.add(_Entry());
                _dirty = true;
              }),
        icon: const Icon(Icons.add),
        label: Text('Add $noun'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: _canLeave || (!_dirty && !_saving),
    onPopInvokedWithResult: (didPop, result) async {
      if (didPop || _saving) return;
      if (await confirmAction(
            context,
            title: 'Discard changes?',
            message: 'Your unsaved visit details will be lost.',
            action: 'Discard',
          ) &&
          mounted) {
        setState(() => _canLeave = true);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) Navigator.pop(context);
        });
      }
    },
    child: Scaffold(
      appBar: AppBar(
        title: Text(widget.visit == null ? 'Add medical visit' : 'Edit visit'),
      ),
      body: Form(
        key: _form,
        onChanged: () {
          if (!_dirty) setState(() => _dirty = true);
        },
        child: PageBody(
          children: [
            Text(
              widget.visit == null
                  ? 'Keep the details together'
                  : 'Update this visit',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'A separate record for every visit. Fields marked * are required.',
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              key: const Key('visitDoctor'),
              initialValue: _doctorId,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Doctor *'),
              items: widget.store.doctors
                  .map(
                    (doctor) => DropdownMenuItem(
                      value: doctor.id,
                      child: Text(doctor.name, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: _saving
                  ? null
                  : (value) => setState(() {
                      _doctorId = value;
                      _facility.text = widget.store.doctor(value!)!.facility;
                      _dirty = true;
                    }),
              validator: (value) => value == null ? 'Choose a doctor' : null,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: _saving ? null : _pickDate,
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: Text(dateLabel(_date)),
                ),
                OutlinedButton.icon(
                  onPressed: _saving ? null : _pickTime,
                  icon: const Icon(Icons.schedule),
                  label: Text(TimeOfDay.fromDateTime(_date).format(context)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('visitReason'),
              controller: _reason,
              enabled: !_saving,
              maxLength: 200,
              decoration: const InputDecoration(
                labelText: 'Visit reason *',
                hintText: 'What was the visit for?',
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter a visit reason'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _facility,
              enabled: !_saving,
              maxLength: 200,
              decoration: const InputDecoration(
                labelText: 'Hospital or clinic (optional)',
              ),
            ),
            const SectionTitle('Diagnosis & notes'),
            TextFormField(
              key: const Key('visitDiagnosis'),
              controller: _diagnosis,
              enabled: !_saving,
              maxLength: 2000,
              minLines: 2,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Diagnosis (optional)',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('visitNotes'),
              controller: _notes,
              enabled: !_saving,
              maxLength: 10000,
              minLines: 3,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'Symptoms, advice or details you want to remember',
              ),
            ),
            const SectionTitle('Medicines (optional)'),
            ..._entryFields(_medicines, true),
            const SectionTitle('Tests (optional)'),
            const Text(
              'Files linked to a removed test stay attached to this visit.',
              style: TextStyle(fontSize: 13),
            ),
            ..._entryFields(_tests, false),
            const SectionTitle('Follow-up (optional)'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  key: const Key('followUpDate'),
                  icon: const Icon(Icons.event_outlined),
                  label: Text(
                    _followUp == null
                        ? 'Record a follow-up date'
                        : dateLabel(_followUp!),
                  ),
                  onPressed: _saving
                      ? null
                      : () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _followUp ?? DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2101),
                          );
                          if (picked != null && mounted) {
                            setState(() {
                              _followUp = picked;
                              _dirty = true;
                            });
                          }
                        },
                ),
                if (_followUp != null)
                  TextButton(
                    onPressed: _saving
                        ? null
                        : () => setState(() {
                            _followUp = null;
                            _dirty = true;
                          }),
                    child: const Text('Remove date'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Record only a date you were given. This does not create a reminder.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 24),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            FilledButton.icon(
              key: const Key('saveVisit'),
              onPressed: _saving ? null : _save,
              icon: Icon(_saving ? Icons.hourglass_top : Icons.check),
              label: Text(_saving ? 'Saving…' : 'Save visit'),
            ),
            const SizedBox(height: 12),
            const Text(
              'Saved on this device. Account sync is not connected.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    ),
  );
}
