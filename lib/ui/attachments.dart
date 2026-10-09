import 'dart:io';

import 'package:flutter/material.dart';

import '../domain/records.dart';
import '../state/medical_store.dart';
import '../services/attachment_files.dart';
import '../services/attachment_gateway.dart';
import 'theme.dart';
import 'widgets.dart';

String attachmentSize(int bytes) => bytes >= 1024 * 1024
    ? '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB'
    : '${(bytes / 1024).ceil()} KB';

Future<void> addAttachment(
  BuildContext context,
  MedicalStore store, {
  String? visitId,
  String? testId,
  AttachmentPicker picker = const NativeAttachmentPicker(),
}) async {
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => AttachmentImportSheet(
      store: store,
      visitId: visitId,
      testId: testId,
      picker: picker,
    ),
  );
  if (saved == true && context.mounted) {
    showMessage(context, 'Attachment saved on this device');
  }
}

class AttachmentImportSheet extends StatefulWidget {
  const AttachmentImportSheet({
    super.key,
    required this.store,
    this.visitId,
    this.testId,
    this.picker = const NativeAttachmentPicker(),
  });
  final MedicalStore store;
  final String? visitId;
  final String? testId;
  final AttachmentPicker picker;
  @override
  State<AttachmentImportSheet> createState() => _AttachmentImportSheetState();
}

class _AttachmentImportSheetState extends State<AttachmentImportSheet> {
  late String? _visitId = widget.visitId;
  late String? _testId = widget.testId;
  bool _saving = false;
  bool _saved = false;
  String? _error;
  Future<void> _pick() async {
    if (_visitId == null) {
      setState(() => _error = 'Choose the visit this file belongs to.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final chosen = await widget.picker.pick();
      if (chosen == null || !mounted) return;
      await widget.store.addAttachment(
        visitId: _visitId!,
        testId: _testId,
        name: chosen.name,
        content: chosen.read(),
      );
      if (!mounted) return;
      setState(() => _saved = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context, true);
      });
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error is AttachmentException ? error.message : 'Could not save this file. Your existing records are unchanged. Check available storage and try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final visit = widget.store.visit(_visitId ?? '');
    return PopScope(
      canPop: !_saving || _saved,
      child: FractionallySizedBox(
        heightFactor: .85,
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
                        'Add attachment',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close attachment form',
                      onPressed: _saving ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView(
                    children: [
                      const SizedBox(height: 12),
                      const Text(
                        'Choose the visit and, optionally, the test this document belongs to.',
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        key: const Key('attachmentVisit'),
                        initialValue: _visitId,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Visit *'),
                        items: widget.store.visits
                            .map(
                              (v) => DropdownMenuItem(
                                value: v.id,
                                child: Text(
                                  '${dateLabel(v.date)} · ${v.reason}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: _saving
                            ? null
                            : (id) => setState(() {
                                _visitId = id;
                                _testId = null;
                                _error = null;
                              }),
                      ),
                      if (visit != null) ...[
                        const SizedBox(height: 8),
                        Text(widget.store.doctor(visit.doctorId)!.name),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          key: ValueKey('test:$_visitId:$_testId'),
                          initialValue: _testId ?? '',
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Link to a test (optional)',
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: '',
                              child: Text('Whole visit'),
                            ),
                            ...visit.tests.map(
                              (t) => DropdownMenuItem(
                                value: t.id,
                                child: Text(
                                  t.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                          onChanged: _saving
                              ? null
                              : (id) => setState(
                                  () => _testId = id == '' ? null : id,
                                ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      const Text(
                        'PDF, JPEG, PNG or WebP · Up to 25 MB\nA copy is kept with your journal, even if the original is moved or deleted.',
                      ),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            _error!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  key: const Key('chooseAttachment'),
                  onPressed: _saving || widget.store.busy ? null : _pick,
                  icon: Icon(_saving ? Icons.hourglass_top : Icons.attach_file),
                  label: Text(_saving ? 'Saving file…' : 'Choose image or PDF'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AttachmentRow extends StatefulWidget {
  const AttachmentRow({
    super.key,
    required this.store,
    required this.attachment,
    this.showVisit = false,
    this.opener = const NativeAttachmentOpener(),
  });
  final MedicalStore store;
  final Attachment attachment;
  final bool showVisit;
  final AttachmentOpener opener;
  @override
  State<AttachmentRow> createState() => _AttachmentRowState();
}

class _AttachmentRowState extends State<AttachmentRow> {
  bool _opening = false;
  Future<void> _open() async {
    setState(() => _opening = true);
    try {
      final files = widget.store.files;
      if (files == null) {
        throw const AttachmentException(
          'Attachment storage is unavailable. Please restart the app.',
        );
      }
      final file = await files.resolve(widget.attachment.storedName);
      if (!mounted) return;
      if (widget.attachment.isImage) {
        await Navigator.push<void>(
          context,
          MaterialPageRoute(
            builder: (_) => AttachmentPreview(
              file: file,
              attachment: widget.attachment,
              opener: widget.opener,
            ),
          ),
        );
      } else {
        await widget.opener.open(file.path, widget.attachment.mimeType);
      }
    } catch (error) {
      if (mounted) {
        showMessage(
          context,
          error is AttachmentException
              ? error.message
              : 'Could not open this file. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  Future<void> _remove() async {
    if (!await confirmAction(
      context,
      title: 'Remove attachment?',
      message:
          'Remove “${widget.attachment.name}” from this visit and this device? The original file outside the app will be kept.',
      action: 'Remove',
    )) {
      return;
    }
    try {
      await widget.store.removeAttachment(widget.attachment.id);
      if (mounted) showMessage(context, 'Attachment removed');
    } catch (_) {
      if (mounted) {
        showMessage(
          context,
          'Could not remove this attachment. Please try again.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.attachment;
    final visit = widget.store.visit(a.visitId);
    final test = visit?.tests.where((t) => t.id == a.testId).firstOrNull;
    return Column(
      children: [
        ListTile(
          key: ValueKey('attachment:${a.id}'),
          contentPadding: const EdgeInsets.symmetric(vertical: 6),
          leading: Icon(
            a.isImage ? Icons.image_outlined : Icons.picture_as_pdf_outlined,
            color: journalTeal,
          ),
          title: Text(a.name, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            [
              attachmentSize(a.size),
              if (test != null) test.name,
              if (widget.showVisit && visit != null)
                '${dateLabel(visit.date)} · ${visit.reason}',
            ].join(' · '),
          ),
          onTap: _opening ? null : _open,
          trailing: PopupMenuButton<String>(
            tooltip: 'Attachment options',
            enabled: !_opening && !widget.store.busy,
            onSelected: (action) {
              if (action == 'remove') {
                _remove();
              } else {
                _open();
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'open', child: Text('Open')),
              const PopupMenuItem(
                value: 'remove',
                child: Text('Remove attachment'),
              ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }
}

class AttachmentPreview extends StatelessWidget {
  const AttachmentPreview({
    super.key,
    required this.file,
    required this.attachment,
    required this.opener,
  });
  final File file;
  final Attachment attachment;
  final AttachmentOpener opener;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Image preview')),
    body: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              attachment.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: InteractiveViewer(
              minScale: .5,
              maxScale: 5,
              child: Image.file(
                file,
                fit: BoxFit.contain,
                errorBuilder: (_, error, stack) => const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'This image could not be read. The file may be missing or damaged. You can remove it and add the original again.',
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed: () async {
                try {
                  await opener.open(file.path, attachment.mimeType);
                } catch (error) {
                  if (context.mounted) {
                    showMessage(
                      context,
                      error is AttachmentException
                          ? error.message
                          : 'Could not open the image.',
                    );
                  }
                }
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open in another app'),
            ),
          ),
        ],
      ),
    ),
  );
}
