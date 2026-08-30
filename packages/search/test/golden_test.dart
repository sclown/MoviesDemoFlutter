//
//  golden_test.dart
//
//  Run `flutter test --update-goldens` in this package to re-record.
//

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:search/search.dart';

import 'fixtures.dart';
import 'test_harness.dart';

const _iPhoneSize = Size(390, 844);

void main() {
  Future<void> pumpOverlay(WidgetTester tester, SearchState state) async {
    tester.view
      ..physicalSize = _iPhoneSize
      ..devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(harnessSearchOverlay(searchCubitMock(state)));
    // A fixed pump, not pumpAndSettle: the progress spinners never settle.
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('search-searching', (tester) async {
    await pumpOverlay(tester, searchingState());

    await expectLater(
      find.byType(SearchOverlay),
      matchesGoldenFile('goldens/search_searching.png'),
    );
  });

  testWidgets('search-empty', (tester) async {
    await pumpOverlay(tester, noResultsState());

    await expectLater(
      find.byType(SearchOverlay),
      matchesGoldenFile('goldens/search_empty.png'),
    );
  });

  testWidgets('search-results-3', (tester) async {
    await pumpOverlay(tester, resultsState(3));

    await expectLater(
      find.byType(SearchOverlay),
      matchesGoldenFile('goldens/search_results_3.png'),
    );
  });

  testWidgets('search-idle', (tester) async {
    await pumpOverlay(tester, SearchState.empty());

    await expectLater(
      find.byType(SearchOverlay),
      matchesGoldenFile('goldens/search_idle.png'),
    );
  });
}
