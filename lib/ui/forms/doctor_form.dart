import 'package:flutter/material.dart';

import '../../domain/records.dart';
import '../../state/medical_store.dart';
import '../widgets.dart';

class DoctorForm extends StatefulWidget {
  const DoctorForm({super.key, required this.store, this.doctor});
  final MedicalStore store;
  final Doctor? doctor;
  @override
  State<DoctorForm> createState() => _DoctorFormState();
}

class _DoctorFormState extends State<DoctorForm> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.doctor?.name);
  late final _specialty = TextEditingController(text: widget.doctor?.specialty);
  late final _facility = TextEditingController(text: widget.doctor?.facility);
  late final _phone = TextEditingController(text: widget.doctor?.phone);
  bool _saving = false;
  bool _dirty = false;
  bool _canLeave = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_name, _specialty, _facility, _phone]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final fieldsValid = _form.currentState!.validate();
    if (!fieldsValid || _name.text.trim().isEmpty) {
      setState(() => _error = 'Enter the doctor’s name above.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final doctor = Doctor(
      id: widget.doctor?.id ?? MedicalStore.newId(),
      name: _name.text,
      specialty: _specialty.text,
      facility: _facility.text,
      phone: _phone.text,
    );
    try {
      await widget.store.saveDoctor(doctor);
      if (!mounted) return;
      setState(() {
        _canLeave = true;
        _saving = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context, doctor.id);
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Could not save this doctor. Your entries are still here. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: _canLeave || (!_dirty && !_saving),
    onPopInvokedWithResult: (didPop, result) async {
      if (didPop || _saving) return;
      if (await confirmAction(
            context,
            title: 'Discard changes?',
            message: 'Your unsaved doctor details will be lost.',
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
        title: Text(widget.doctor == null ? 'Add doctor' : 'Edit doctor'),
      ),
      body: Form(
        key: _form,
        onChanged: () {
          if (!_dirty) setState(() => _dirty = true);
        },
        child: PageBody(
          children: [
            const Text(
              'Your care team',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add a doctor once, then keep each visit in its own record. Only the name is required.',
            ),
            const SizedBox(height: 24),
            TextFormField(
              key: const Key('doctorName'),
              controller: _name,
              enabled: !_saving,
              textCapitalization: TextCapitalization.words,
              maxLength: 120,
              decoration: const InputDecoration(
                labelText: 'Doctor name *',
                hintText: 'Enter full name',
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter the doctor’s name'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _specialty,
              enabled: !_saving,
              maxLength: 120,
              decoration: const InputDecoration(
                labelText: 'Specialty (optional)',
              ),
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
            const SizedBox(height: 16),
            TextFormField(
              controller: _phone,
              enabled: !_saving,
              keyboardType: TextInputType.phone,
              maxLength: 40,
              decoration: const InputDecoration(labelText: 'Phone (optional)'),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            FilledButton.icon(
              key: const Key('saveDoctor'),
              onPressed: _saving ? null : _save,
              icon: Icon(_saving ? Icons.hourglass_top : Icons.check),
              label: Text(_saving ? 'Saving…' : 'Save doctor'),
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
