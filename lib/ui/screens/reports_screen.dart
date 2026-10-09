import 'package:flutter/material.dart';

import '../../state/medical_store.dart';
import '../../services/attachment_gateway.dart';
import '../actions.dart';
import '../attachments.dart';
import '../widgets.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({
    super.key,
    required this.store,
    this.picker = const NativeAttachmentPicker(),
    this.opener = const NativeAttachmentOpener(),
  });
  final MedicalStore store;
  final AttachmentPicker picker;
  final AttachmentOpener opener;
  @override
  Widget build(BuildContext context) => PageBody(
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              'Reports',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          IconButton(
            key: const Key('addAttachment'),
            tooltip: 'Add attachment',
            onPressed: store.busy
                ? null
                : () {
                    if (store.visits.isEmpty) {
                      showMessage(
                        context,
                        'Add a visit first so your file has a record to belong to.',
                      );
                    } else {
                      addAttachment(context, store, picker: picker);
                    }
                  },
            icon: const Icon(Icons.attach_file),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Text(
        '${counted(store.attachments.length, 'saved file')} · Images & PDFs',
      ),
      if (store.attachments.isEmpty)
        EmptyState(
          icon: Icons.folder_open_outlined,
          title: 'Keep your documents together',
          message: 'Attach a report or image to a visit or test. A copy stays in your journal on this device.',
          action: store.visits.isEmpty
              ? OutlinedButton.icon(
                  onPressed: () => addVisit(context, store),
                  icon: const Icon(Icons.add),
                  label: const Text('Add a visit'),
                )
              : OutlinedButton.icon(
                  onPressed: () =>
                      addAttachment(context, store, picker: picker),
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Add attachment'),
                ),
        )
      else
        ...store.attachments.map(
          (a) => AttachmentRow(
            key: ValueKey(a.id),
            store: store,
            attachment: a,
            showVisit: true,
            opener: opener,
          ),
        ),
      SectionTitle('Recorded tests (${store.testCount})'),
      if (store.testCount == 0)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text('No tests recorded'),
        )
      else
        ...store.visits.expand(
          (visit) => visit.tests.map(
            (test) => Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  title: Text(
                    test.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    '${dateLabel(visit.date)} · ${store.doctor(visit.doctorId)!.name}\n${test.result.isEmpty ? 'No result recorded' : test.result}',
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    tooltip: 'Attach file to ${test.name}',
                    onPressed: store.busy
                        ? null
                        : () => addAttachment(
                            context,
                            store,
                            visitId: visit.id,
                            testId: test.id,
                            picker: picker,
                          ),
                    icon: const Icon(Icons.attach_file),
                  ),
                  onTap: () => openVisit(context, store, visit.id),
                ),
                const Divider(),
              ],
            ),
          ),
        ),
    ],
  );
}
