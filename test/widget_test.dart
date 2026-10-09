import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_medical_history/app.dart';
import 'package:my_medical_history/domain/records.dart';
import 'package:my_medical_history/state/medical_store.dart';
import 'package:my_medical_history/ui/forms/visit_form.dart';
import 'package:my_medical_history/ui/theme.dart';

import 'support/core_flow.dart';
import 'support/memory_repository.dart';

void main() {
  testWidgets(
    'long visit form validates required fields outside the viewport',
    (tester) async {
      tester.view.physicalSize = const Size(390, 650);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = MedicalStore(MemoryRepository());
      await store.saveDoctor(const Doctor(id: 'd', name: 'Doctor'));
      await tester.pumpWidget(
        MaterialApp(
          theme: medicalTheme(),
          home: VisitForm(store: store),
        ),
      );
      for (var i = 0; i < 4; i++) {
        await tapKey(tester, 'addMedicine', scroll: true);
      }
      await tapKey(tester, 'saveVisit', scroll: true);
      expect(store.visits, isEmpty);
      expect(
        find.text(
          'Check the required fields above, including any medicine or test you added.',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      store.dispose();
    },
  );

  testWidgets('doctor to independent visits, history, edit and delete', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = MedicalStore(MemoryRepository());
    await store.load();
    await exerciseCoreFlow(tester, store);
    await tester.pumpWidget(const SizedBox.shrink());
    store.dispose();
  });

  testWidgets('empty account navigates at narrow width and large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final store = MedicalStore(MemoryRepository());
    await store.load();
    await tester.pumpWidget(MedicalApp(store: store));
    await tester.pumpAndSettle();
    for (final tab in [
      'navDoctors',
      'navHistory',
      'navReports',
      'navSettings',
      'navHome',
    ]) {
      await tapKey(tester, tab);
      expect(tester.takeException(), isNull);
    }
    expect(store.doctors, isEmpty);
    expect(store.visits, isEmpty);
    await tester.pumpWidget(const SizedBox.shrink());
    store.dispose();
  });
}
