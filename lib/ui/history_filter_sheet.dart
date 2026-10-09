import 'package:flutter/material.dart';

import '../domain/history_filter.dart';
import '../domain/records.dart';
import 'widgets.dart';

class HistoryFilterSheet extends StatefulWidget {
  const HistoryFilterSheet({
    super.key,
    required this.filter,
    required this.doctors,
  });
  final HistoryFilter filter;
  final List<Doctor> doctors;
  @override
  State<HistoryFilterSheet> createState() => _HistoryFilterSheetState();
}

class _HistoryFilterSheetState extends State<HistoryFilterSheet> {
  late String? _doctor = widget.filter.doctorId;
  late DateTime? _from = widget.filter.from;
  late DateTime? _to = widget.filter.to;
  late bool _medicines = widget.filter.withMedicines;
  late bool _tests = widget.filter.withTests;
  String? _error;
  Future<void> _date(bool start) async {
    final value = await showDatePicker(
      context: context,
      initialDate: (start ? _from : _to) ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (value != null && mounted) {
      setState(() {
        if (start) {
          _from = value;
        } else {
          _to = value;
        }
        _error = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) => FractionallySizedBox(
    heightFactor: .9,
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Filter history',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: 'Close filters',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                children: [
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    key: ValueKey(_doctor),
                    initialValue: _doctor ?? '',
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Doctor'),
                    items: [
                      const DropdownMenuItem(
                        value: '',
                        child: Text('All doctors'),
                      ),
                      ...widget.doctors.map(
                        (d) => DropdownMenuItem(
                          value: d.id,
                          child: Text(d.name, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _doctor = value == '' ? null : value),
                  ),
                  const SectionTitle('Visit date'),
                  OutlinedButton.icon(
                    key: const Key('filterFrom'),
                    onPressed: () => _date(true),
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: Text(
                      _from == null
                          ? 'From any date'
                          : 'From ${dateLabel(_from!)}',
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    key: const Key('filterTo'),
                    onPressed: () => _date(false),
                    icon: const Icon(Icons.event_outlined),
                    label: Text(
                      _to == null ? 'To any date' : 'To ${dateLabel(_to!)}',
                    ),
                  ),
                  if (_from != null || _to != null)
                    TextButton(
                      onPressed: () => setState(() {
                        _from = null;
                        _to = null;
                        _error = null;
                      }),
                      child: const Text('Clear dates'),
                    ),
                  const SectionTitle('Included in the visit'),
                  CheckboxListTile(
                    key: const Key('filterMedicines'),
                    contentPadding: EdgeInsets.zero,
                    title: const Text('With medicines'),
                    value: _medicines,
                    onChanged: (v) => setState(() => _medicines = v!),
                  ),
                  CheckboxListTile(
                    key: const Key('filterTests'),
                    contentPadding: EdgeInsets.zero,
                    title: const Text('With tests'),
                    value: _tests,
                    onChanged: (v) => setState(() => _tests = v!),
                  ),
                  if (_error != null)
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              key: const Key('applyFilters'),
              onPressed: () {
                if (_from != null && _to != null && _from!.isAfter(_to!)) {
                  setState(
                    () => _error =
                        'The end date must be on or after the start date.',
                  );
                  return;
                }
                Navigator.pop(
                  context,
                  HistoryFilter(
                    doctorId: _doctor,
                    from: _from,
                    to: _to,
                    withMedicines: _medicines,
                    withTests: _tests,
                  ),
                );
              },
              child: const Text('Apply filters'),
            ),
            TextButton(
              onPressed: () => setState(() {
                _doctor = null;
                _from = null;
                _to = null;
                _medicines = false;
                _tests = false;
                _error = null;
              }),
              child: const Text('Reset filters'),
            ),
          ],
        ),
      ),
    ),
  );
}
