import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_medical_history/app.dart';
import 'package:my_medical_history/domain/records.dart';
import 'package:my_medical_history/services/attachment_files.dart';
import 'package:my_medical_history/services/attachment_gateway.dart';
import 'package:my_medical_history/state/medical_store.dart';
import 'package:my_medical_history/ui/attachments.dart';
import 'package:my_medical_history/ui/screens/reports_screen.dart';
import 'package:my_medical_history/ui/theme.dart';
import 'package:my_medical_history/ui/widgets.dart';

import 'support/core_flow.dart';
import 'support/memory_repository.dart';
import '../integration_test/attachment_fixture.dart';

class FixturePicker implements AttachmentPicker {
  PickedAttachment? selection;
  @override
  Future<PickedAttachment?> pick() async => selection;
}

class RecordingOpener implements AttachmentOpener {
  String? path;
  String? mime;
  @override
  Future<void> open(String path, String mimeType) async {
    this.path = path;
    mime = mimeType;
  }
}

Future<MedicalStore> populatedStore({AttachmentFiles? files}) async {
  final store = MedicalStore(MemoryRepository(), files: files);
  await store.saveDoctor(
    const Doctor(
      id: 'doctor',
      name: 'Dr. Existing Person',
      specialty: 'Recorded specialty',
      facility: 'Recorded facility',
    ),
  );
  await store.saveVisit(
    Visit(
      id: 'first',
      doctorId: 'doctor',
      date: DateTime(2026, 10, 9, 9),
      reason: '  Recorded reason  ',
      diagnosis: '  A recorded diagnosis\r\n',
      notes: '  Exact clinical text\nSecond line  ',
      facility: ' Clinic ',
      followUp: DateTime(2090, 1, 5),
      medicines: const [
        Medicine(
          name: '  Medicine name  ',
          instructions: ' Dose as entered\n ',
        ),
      ],
      tests: const [
        MedicalTest(
          id: 'test-one',
          name: 'Recorded test',
          result: ' Exact result ',
        ),
      ],
    ),
  );
  await store.saveVisit(
    Visit(
      id: 'second',
      doctorId: 'doctor',
      date: DateTime(2026, 10, 8),
      reason: 'Independent visit',
    ),
  );
  return store;
}

void phone(WidgetTester tester, {double scale = 1}) {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

Future<void> flushIo(WidgetTester tester, bool Function() done) async {
  for (var i = 0; i < 150 && !done(); i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump();
  }
  expect(done(), isTrue, reason: 'The asynchronous operation did not finish');
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('History search and filters survive details and tab changes', (
    tester,
  ) async {
    phone(tester);
    final store = await populatedStore();
    await tester.pumpWidget(MedicalApp(store: store));
    await tapKey(tester, 'navHistory');
    await enter(tester, 'historySearch', 'recorded');
    await tapKey(tester, 'historyFilters');
    await tester.tap(find.byKey(const Key('filterTests')));
    await tapKey(tester, 'applyFilters');
    expect(find.text('With tests'), findsOneWidget);
    final card = find.widgetWithText(VisitCard, '  Recorded reason  ');
    await reveal(tester, card);
    await tester.tap(card);
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('historySearch')))
          .controller!
          .text,
      'recorded',
    );
    expect(find.text('With tests'), findsOneWidget);
    await tapKey(tester, 'navDoctors');
    await tapKey(tester, 'navHistory');
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('historySearch')))
          .controller!
          .text,
      'recorded',
    );
    expect(find.text('With tests'), findsOneWidget);
    expect(find.text('Independent visit'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    store.dispose();
  });

  testWidgets(
    'editing one visit preserves untouched clinical text and stable test IDs exactly',
    (tester) async {
      phone(tester);
      final store = await populatedStore();
      final first = store.visit('first')!.toMap();
      final second = store.visit('second')!.toMap();
      await tester.pumpWidget(MedicalApp(store: store));
      await tapKey(tester, 'navHistory');
      final card = find.widgetWithText(VisitCard, '  Recorded reason  ');
      await reveal(tester, card);
      await tester.tap(card);
      await tester.pumpAndSettle();
      await tapKey(tester, 'editVisit');
      await enter(tester, 'visitReason', '  Intended change only  ');
      await tapKey(tester, 'saveVisit', scroll: true);
      expect(store.visit('first')!.toMap(), {
        ...first,
        'reason': '  Intended change only  ',
      });
      expect(store.visit('second')!.toMap(), second);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      store.dispose();
    },
  );

  testWidgets(
    'populated journal and filter sheet remain usable at 200 percent text',
    (tester) async {
      phone(tester, scale: 2);
      final store = await populatedStore();
      await tester.pumpWidget(MedicalApp(store: store));
      await tester.pumpAndSettle();
      for (final tab in [
        'navDoctors',
        'navReports',
        'navSettings',
        'navHistory',
      ]) {
        await tapKey(tester, tab);
        expect(tester.takeException(), isNull);
      }
      await tapKey(tester, 'historyFilters', scroll: true);
      await tester.scrollUntilVisible(
        find.byKey(const Key('filterTests')),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.ensureVisible(find.byKey(const Key('filterTests')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('filterTests')));
      await tapKey(tester, 'applyFilters');
      expect(find.text('With tests'), findsOneWidget);
      await reveal(
        tester,
        find.widgetWithText(VisitCard, '  Recorded reason  '),
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      store.dispose();
    },
  );

  testWidgets(
    'attachment import, PDF open, cancellation, removal and missing-file feedback',
    (tester) async {
      phone(tester);
      final directory = (await tester.runAsync(
        () => Directory.systemTemp.createTemp('journal_ui_'),
      ))!;
      final store = await populatedStore(files: AttachmentFiles(directory));
      final picker = FixturePicker();
      final opener = RecordingOpener();
      await tester.pumpWidget(
        MaterialApp(
          theme: medicalTheme(),
          home: ListenableBuilder(
            listenable: store,
            builder: (context, _) => Scaffold(
              body: ReportsScreen(store: store, picker: picker, opener: opener),
            ),
          ),
        ),
      );
      await tapKey(tester, 'addAttachment');
      await tester.tap(find.byKey(const Key('attachmentVisit')));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Recorded reason').last);
      await tester.pumpAndSettle();
      // Canceling the native picker creates neither metadata nor files.
      await tapKey(tester, 'chooseAttachment');
      expect(store.attachments, isEmpty);
      picker.selection = PickedAttachment(
        'Report.pdf',
        () => Stream.value(utf8.encode('%PDF-1.4\nFixture\n%%EOF')),
      );
      await tester.runAsync(() async {
        await tester.tap(find.byKey(const Key('chooseAttachment')));
        for (var i = 0; i < 100 && store.attachments.isEmpty; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 20));
        }
      });
      await flushIo(tester, () => store.attachments.isNotEmpty && !store.busy);
      expect(store.attachments.single.visitId, 'first');
      final attachment = store.attachments.single;
      await tester.tap(find.text('Report.pdf'));
      await flushIo(tester, () => opener.path != null);
      expect(opener.path, store.files!.file(attachment.storedName).path);
      expect(opener.mime, 'application/pdf');
      await tester.tap(find.byTooltip('Attachment options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove attachment'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(store.attachments, hasLength(1));
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await tester.runAsync(() => store.files!.remove(attachment.storedName));
      await tester.tap(find.text('Report.pdf'));
      await flushIo(
        tester,
        () => find
            .textContaining('File missing on this device')
            .evaluate()
            .isNotEmpty,
      );
      await tester.tap(find.byTooltip('Attachment options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove attachment'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove'));
      await flushIo(tester, () => store.attachments.isEmpty && !store.busy);
      await tester.runAsync(
        () => store.addAttachment(
          visitId: 'first',
          name: 'Preview.png',
          content: Stream.value(fixturePng),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Preview.png'));
      await flushIo(
        tester,
        () => find.byType(AttachmentPreview).evaluate().isNotEmpty,
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('This image could not be read'), findsNothing);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.runAsync(
        () => store.removeAttachment(store.attachments.single.id),
      );
      expect(store.visits, hasLength(2));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      // Image disposal is deferred to the next frame by Flutter.
      await tester.pump();
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        // Windows may keep the decoded image open briefly after route disposal.
        for (var i = 0; i < 100; i++) {
          await store.cleanRemovedFiles();
          if (await directory.list().isEmpty) break;
          await Future<void>.delayed(const Duration(milliseconds: 20));
        }
        final remaining = await directory.list().toList();
        final queued = await store.repository.pendingFileDeletions();
        for (final file in remaining) {
          expect(queued, contains(file.uri.pathSegments.last));
          try {
            await file.delete();
          } on FileSystemException catch (error) {
            // The Windows engine can retain a mapped preview until it exits.
            // Only accept a genuine sharing violation with a queued retry.
            expect(Platform.isWindows, isTrue);
            expect(error.osError?.errorCode, 32);
          }
        }
        if (await directory.list().isEmpty) await directory.delete();
      });
      store.dispose();
    },
  );
}
