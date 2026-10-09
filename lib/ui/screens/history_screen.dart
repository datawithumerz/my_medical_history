import 'package:flutter/material.dart';

import '../../domain/history_filter.dart';
import '../../domain/records.dart';
import '../../state/medical_store.dart';
import '../actions.dart';
import '../history_filter_sheet.dart';
import '../widgets.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, required this.store});
  final MedicalStore store;
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _search = TextEditingController();
  final _scroll = ScrollController();
  HistoryFilter _filter = const HistoryFilter();
  @override
  void dispose() {
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _apply(HistoryFilter value) => setState(() => _filter = value);
  Future<void> _filters() async {
    FocusScope.of(context).unfocus();
    final result = await showModalBottomSheet<HistoryFilter>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) =>
          HistoryFilterSheet(filter: _filter, doctors: widget.store.doctors),
    );
    if (result != null && mounted) _apply(result);
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    if (_filter.doctorId != null && store.doctor(_filter.doctorId!) == null) {
      _filter = HistoryFilter(
        from: _filter.from,
        to: _filter.to,
        withMedicines: _filter.withMedicines,
        withTests: _filter.withTests,
      );
    }
    final visits = store.visits
        .where(
          (v) => _filter.matches(v, store.doctor(v.doctorId), _search.text),
        )
        .toList();
    final groups = <String, List<Visit>>{};
    for (final visit in visits) {
      groups.putIfAbsent(monthLabel(visit.date), () => []).add(visit);
    }
    return PageBody(
      controller: _scroll,
      children: [
        JournalHeading(
          'History',
          action: FilledButton.icon(
            key: const Key('historyAddVisit'),
            onPressed: () => addVisit(context, store),
            icon: const Icon(Icons.add),
            label: const Text('Add'),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('historySearch'),
          controller: _search,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            labelText: 'Search history',
            suffixIcon: _search.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    onPressed: () {
                      _search.clear();
                      setState(() {});
                    },
                    icon: const Icon(Icons.close),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          children: [
            Text(
              '${visits.length} of ${store.visits.length} visits',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            TextButton.icon(
              key: const Key('historyFilters'),
              onPressed: _filters,
              icon: const Icon(Icons.tune, size: 20),
              label: Text(
                _filter.count == 0 ? 'Filters' : 'Filters (${_filter.count})',
              ),
            ),
          ],
        ),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            if (_filter.doctorId != null)
              InputChip(
                label: Text(store.doctor(_filter.doctorId!)!.name),
                onDeleted: () => _apply(
                  HistoryFilter(
                    from: _filter.from,
                    to: _filter.to,
                    withMedicines: _filter.withMedicines,
                    withTests: _filter.withTests,
                  ),
                ),
              ),
            if (_filter.from != null || _filter.to != null)
              InputChip(
                label: Text(
                  '${_filter.from == null ? 'Any date' : dateLabel(_filter.from!)} – ${_filter.to == null ? 'Any date' : dateLabel(_filter.to!)}',
                ),
                onDeleted: () => _apply(
                  HistoryFilter(
                    doctorId: _filter.doctorId,
                    withMedicines: _filter.withMedicines,
                    withTests: _filter.withTests,
                  ),
                ),
              ),
            if (_filter.withMedicines)
              InputChip(
                label: const Text('With medicines'),
                onDeleted: () => _apply(
                  HistoryFilter(
                    doctorId: _filter.doctorId,
                    from: _filter.from,
                    to: _filter.to,
                    withTests: _filter.withTests,
                  ),
                ),
              ),
            if (_filter.withTests)
              InputChip(
                label: const Text('With tests'),
                onDeleted: () => _apply(
                  HistoryFilter(
                    doctorId: _filter.doctorId,
                    from: _filter.from,
                    to: _filter.to,
                    withMedicines: _filter.withMedicines,
                  ),
                ),
              ),
          ],
        ),
        if (visits.isEmpty)
          EmptyState(
            icon: Icons.menu_book_outlined,
            title: store.visits.isEmpty
                ? 'No visits yet'
                : 'No matching visits',
            message: store.visits.isEmpty
                ? 'Add a visit to begin your dated medical journal.'
                : 'Adjust your search or filters to see more entries.',
          )
        else
          ...groups.entries.expand(
            (group) => [
              SectionTitle(group.key),
              ...group.value.map(
                (v) => VisitCard(
                  visit: v,
                  doctorName: store.doctor(v.doctorId)!.name,
                  attachmentCount: store.attachmentsFor(v.id).length,
                  onOpen: () => openVisit(context, store, v.id),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
