//
//  accessibility_test.dart
//

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures.dart';
import 'test_harness.dart';

const _guidelines = <AccessibilityGuideline>[
  androidTapTargetGuideline,
  iOSTapTargetGuideline,
  textContrastGuideline,
  labeledTapTargetGuideline,
];

void main() {
  Future<void> expectAccessible(WidgetTester tester, Widget app) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(app);
    await tester.pump();
    for (final guideline in _guidelines) {
      await expectLater(tester, meetsGuideline(guideline));
    }
    handle.dispose();
  }

  testWidgets('the results list meets the guidelines', (tester) async {
    await expectAccessible(
      tester,
      harnessSearchOverlay(searchCubitMock(resultsState(3))),
    );
  });

  testWidgets('the empty state meets the guidelines', (tester) async {
    await expectAccessible(
      tester,
      harnessSearchOverlay(searchCubitMock(noResultsState())),
    );
  });

  testWidgets('the error state meets the guidelines', (tester) async {
    await expectAccessible(
      tester,
      harnessSearchOverlay(searchCubitMock(failedState())),
    );
  });

  testWidgets('a result row announces itself as a button', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      harnessSearchOverlay(searchCubitMock(resultsState(3))),
    );
    await tester.pump();

    final row = tester.getSemantics(
      find.bySemanticsIdentifier('searchResult-2'),
    );
    expect(row.hasFlag(SemanticsFlag.isButton), isTrue);
    // The row's own text is merged in, so it reads as one node.
    expect(row.label, contains('Test movie 2'));

    handle.dispose();
  });
}
