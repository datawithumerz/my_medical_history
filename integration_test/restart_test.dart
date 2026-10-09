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
  testWidgets('records survive a fresh Android app process', (tester) async {
    final path = p.join(await getDatabasesPath(), 'core_flow_test.db');
    expect(
      await databaseExists(path),
      isTrue,
      reason: 'Run core_flow_test.dart on this device first.',
    );
    final repository = await SqliteMedicalRepository.open(path: path);
    final files = await testAttachmentFiles();
    final store = MedicalStore(repository, files: files);
    await store.load();
    expect(store.doctors.single.name, 'Dr. Test Physician');
    expect(store.visits.single.reason, 'Independent follow-up');
    expect(store.visits.single.medicines, isEmpty);
    expect(store.attachments, hasLength(2));
    for (final attachment in store.attachments) {
      final file = await files.resolve(attachment.storedName);
      expect(
        await file.readAsBytes(),
        attachment.isImage ? fixturePng : fixturePdf,
      );
    }
    await tester.pumpWidget(MedicalApp(store: store));
    await tester.pumpAndSettle();
    await tapKey(tester, 'navHistory');
    await reveal(tester, find.text('Independent follow-up'));
    await tester.tap(find.text('Independent follow-up'));
    await tester.pumpAndSettle();
    expect(find.text('Visit details'), findsOneWidget);
    await reveal(tester, find.text('Verification.png'));
    await tester.tap(find.text('Verification.png'));
    await tester.pumpAndSettle();
    expect(find.text('Image preview'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    for (final attachment in List.of(store.attachments)) {
      await store.removeAttachment(attachment.id);
    }
    store.dispose();
    await repository.close();
    await deleteDatabase(path);
  });
}
