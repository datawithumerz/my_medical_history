import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_medical_history/app.dart';
import 'package:my_medical_history/state/medical_store.dart';
import 'package:my_medical_history/ui/widgets.dart';

Future<void> reveal(WidgetTester tester, Finder finder) async {
  final scrollable = find
      .descendant(
        of: find.byType(PageBody).last,
        matching: find.byType(Scrollable),
      )
      .first;
  await tester.scrollUntilVisible(
    finder,
    240,
    scrollable: scrollable,
    maxScrolls: 45,
  );
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

Future<void> tapKey(
  WidgetTester tester,
  String key, {
  bool scroll = false,
}) async {
  final finder = find.byKey(Key(key));
  if (scroll) await reveal(tester, finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> enter(WidgetTester tester, String key, String text) async {
  final finder = find.byKey(Key(key));
  await reveal(tester, finder);
  await tester.enterText(finder, text);
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();
}

/// Runs the same user journey against an in-memory adapter and real Android SQLite.
/// The caller supplies an empty store. It leaves one doctor and one untouched visit.
Future<void> exerciseCoreFlow(WidgetTester tester, MedicalStore store) async {
  await tester.pumpWidget(MedicalApp(store: store));
  await tester.pumpAndSettle();
  expect(store.doctors, isEmpty);
  expect(store.visits, isEmpty);
  await tapKey(tester, 'navDoctors');
  await tapKey(tester, 'addDoctor');
  await tapKey(tester, 'saveDoctor', scroll: true);
  expect(store.doctors, isEmpty);
  // Return to the start after checking required-field validation.
  await tester.drag(find.byType(ListView).last, const Offset(0, 1000));
  await tester.pumpAndSettle();
  await enter(tester, 'doctorName', 'Dr. Test Physician');
  await tapKey(tester, 'saveDoctor', scroll: true);
  expect(store.doctors, hasLength(1));
  final doctorId = store.doctors.single.id;
  await tapKey(tester, 'doctorAddVisit', scroll: true);
  await enter(tester, 'visitReason', 'Initial assessment');
  await enter(tester, 'visitDiagnosis', 'Recorded diagnosis');
  await enter(tester, 'visitNotes', 'Personal notes from the first visit');
  await tapKey(tester, 'addMedicine', scroll: true);
  await enter(tester, 'medicineName0', 'Recorded medicine');
  await enter(tester, 'medicineDetail0', 'Instructions provided at the visit');
  await tapKey(tester, 'addTest', scroll: true);
  await enter(tester, 'testName0', 'Recorded blood test');
  await enter(tester, 'testDetail0', 'Result entered by the user');
  await tapKey(tester, 'saveVisit', scroll: true);
  expect(find.text('Visit details'), findsOneWidget);
  expect(store.visits, hasLength(1));
  final firstId = store.visits.single.id;
  final persisted = await store.repository.load();
  expect(persisted.visits.single.toMap(), store.visits.single.toMap());
  expect(
    store.visits.single.medicines.single.instructions,
    'Instructions provided at the visit',
  );
  expect(store.testCount, 1);
  await tester.pageBack();
  await tester.pumpAndSettle();
  await tapKey(tester, 'doctorAddVisit', scroll: true);
  await enter(tester, 'visitReason', 'Independent follow-up');
  await tapKey(tester, 'saveVisit', scroll: true);
  expect(store.visits, hasLength(2));
  final second = store.visits.firstWhere((v) => v.id != firstId);
  final secondMap = second.toMap();
  expect(second.doctorId, doctorId);
  expect(second.medicines, isEmpty);
  expect(second.tests, isEmpty);
  expect(second.notes, isEmpty);
  await tester.pageBack();
  await tester.pumpAndSettle();
  await tester.pageBack();
  await tester.pumpAndSettle();
  await tapKey(tester, 'navHistory');
  await enter(tester, 'historySearch', 'Initial assessment');
  final firstCard = find.widgetWithText(VisitCard, 'Initial assessment');
  await reveal(tester, firstCard);
  await tester.tap(firstCard);
  await tester.pumpAndSettle();
  await tapKey(tester, 'editVisit');
  await enter(tester, 'visitReason', 'Updated assessment');
  await tapKey(tester, 'saveVisit', scroll: true);
  expect(find.text('Updated assessment'), findsOneWidget);
  expect(store.visit(firstId)!.diagnosis, 'Recorded diagnosis');
  expect(
    store.visit(firstId)!.tests.single.result,
    'Result entered by the user',
  );
  expect(store.visit(second.id)!.toMap(), secondMap);
  await tapKey(tester, 'deleteVisit');
  await tester.tap(find.text('Cancel'));
  await tester.pumpAndSettle();
  expect(store.visits, hasLength(2));
  await tapKey(tester, 'deleteVisit');
  await tester.tap(find.text('Delete visit'));
  await tester.pumpAndSettle();
  expect(store.visit(firstId), isNull);
  expect(store.visits.single.toMap(), secondMap);
  expect(store.doctors.single.id, doctorId);
  expect(store.medicineCount, 0);
  expect(store.testCount, 0);
  await tapKey(tester, 'navReports');
  expect(find.text('No tests recorded'), findsOneWidget);
  await tapKey(tester, 'navSettings');
  await reveal(tester, find.text('Account sync'));
  expect(find.text('Not connected'), findsWidgets);
  expect(tester.takeException(), isNull);
}
