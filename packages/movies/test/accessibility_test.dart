//
//  accessibility_test.dart
//
//  Flutter's own guidelines, run against each screen: tap targets big enough
//  to hit, text readable against its background, and every tappable node
//  announcing something.
//

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies_data_mocks/movies_data_mocks.dart';

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

  testWidgets('the movies grid meets the guidelines', (tester) async {
    await expectAccessible(
      tester,
      harnessMoviesView(moviesCubitMock(loadedState(4))),
    );
  });

  testWidgets('the error state meets the guidelines', (tester) async {
    await expectAccessible(
      tester,
      harnessMoviesView(moviesCubitMock(errorState())),
    );
  });

  testWidgets('the details screen meets the guidelines', (tester) async {
    await expectAccessible(tester, harnessDetailsView(movieDetails()));
  });

  testWidgets('a grid cell announces itself as a button', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(harnessMoviesView(moviesCubitMock(loadedState(3))));
    await tester.pump();

    final cell = tester.getSemantics(
      find.bySemanticsIdentifier('movieCell-1'),
    );
    expect(cell.label, 'Movie title 1');
    expect(cell.hasFlag(SemanticsFlag.isButton), isTrue);

    handle.dispose();
  });
}
