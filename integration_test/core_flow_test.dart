import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_medical_history/app.dart';
import 'package:my_medical_history/data/sqlite_medical_repository.dart';
import 'package:my_medical_history/state/medical_store.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import '../test/support/core_flow.dart';
import 'attachment_fixture.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('core journey and durable SQLite records on Android', (
    tester,
  ) async {
    // Dedicated test database. Never clear or seed the user's medical_history.db.
    final path = p.join(await getDatabasesPath(), 'core_flow_test.db');
    await deleteDatabase(path);
    var repository = await SqliteMedicalRepository.open(path: path);
    final files = await testAttachmentFiles();
    var store = MedicalStore(repository, files: files);
    await store.load();
    await exerciseCoreFlow(tester, store);
    final expected = store.visits.single.toMap();
    final doctor = store.doctors.single;
    await store.addAttachment(
      visitId: store.visits.single.id,
      name: 'Verification.png',
      content: Stream.value(fixturePng),
    );
    await store.addAttachment(
      visitId: store.visits.single.id,
      name: 'Verification.pdf',
      content: Stream.value(fixturePdf),
    );
    // Exercise the actual database foreign key, independently of store guards.
    await expectLater(
      repository.deleteDoctor(doctor.id),
      throwsA(isA<DatabaseException>()),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    store.dispose();
    await repository.close();
    repository = await SqliteMedicalRepository.open(path: path);
    store = MedicalStore(repository, files: files);
    await store.load();
    expect(store.doctors.single.toMap(), doctor.toMap());
    expect(store.visits.single.toMap(), expected);
    await tester.pumpWidget(MedicalApp(store: store));
    await tester.pumpAndSettle();
    await tapKey(tester, 'navHistory');
    await reveal(tester, find.text('Independent follow-up'));
    expect(find.text('Independent follow-up'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    store.dispose();
    await repository.close();
    // Leave this isolated database for the fresh-process restart test.
  });
}
