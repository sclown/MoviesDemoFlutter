import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:search/src/empty_search_results_view.dart';
import 'package:search/src/search_error_view.dart';
import 'package:search/src/search_result_row.dart';
import 'package:search/src/search_state.dart';

import 'fixtures.dart';
import 'test_harness.dart';

void main() {
  testWidgets('starts as just a search field', (tester) async {
    await tester.pumpWidget(
      harnessSearchOverlay(searchCubitMock(SearchState.empty())),
    );

    expect(find.byType(TextField), findsOne);
    expect(find.text('Search'), findsOne);
    expect(find.byType(SearchResultRow), findsNothing);
  });

  testWidgets('typing forwards the query to the view model', (tester) async {
    final cubit = searchCubitMock(SearchState.empty());
    await tester.pumpWidget(harnessSearchOverlay(cubit));

    await tester.enterText(find.byType(TextField), 'Batman');
    await tester.pump();

    verify(() => cubit.updateSearchQuery('Batman')).called(1);
  });

  testWidgets('shows the results', (tester) async {
    await tester.pumpWidget(
      harnessSearchOverlay(searchCubitMock(resultsState(3))),
    );
    await tester.pump();

    expect(find.byType(SearchResultRow), findsNWidgets(3));
    expect(find.text('Test movie 1'), findsOne);
    expect(find.text('7.5'), findsWidgets);
  });

  testWidgets('shows the error state when the search failed', (tester) async {
    await tester.pumpWidget(harnessSearchOverlay(searchCubitMock(failedState())));
    await tester.pump();

    expect(find.byType(SearchErrorView), findsOne);
    expect(find.text('Search failed'), findsOne);
    expect(find.byType(EmptySearchResultsView), findsNothing);
  });

  testWidgets('shows the empty state', (tester) async {
    await tester.pumpWidget(
      harnessSearchOverlay(searchCubitMock(noResultsState())),
    );
    await tester.pump();

    expect(find.byType(EmptySearchResultsView), findsOne);
    expect(find.text('No results for "xyzzy"'), findsOne);
    expect(find.text('Try a different search term'), findsOne);
  });

  testWidgets('shows a spinner while searching', (tester) async {
    await tester.pumpWidget(
      harnessSearchOverlay(searchCubitMock(searchingState())),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOne);
  });

  testWidgets('tapping a result opens its details', (tester) async {
    final handle = tester.ensureSemantics();
    final cubit = searchCubitMock(resultsState(3));
    await tester.pumpWidget(harnessSearchOverlay(cubit));
    await tester.pump();

    await tester.tap(find.bySemanticsIdentifier('searchResult-2'));

    verify(() => cubit.showDetails(movieId: 2)).called(1);
    handle.dispose();
  });

  testWidgets('the whole row is tappable, not just its text', (tester) async {
    final cubit = searchCubitMock(resultsState(3));
    await tester.pumpWidget(harnessSearchOverlay(cubit));
    await tester.pump();

    // The padding at the right edge of the second row: inside the row, but
    // over none of its children.
    final rect = tester.getRect(find.byType(SearchResultRow).at(1));
    await tester.tapAt(Offset(rect.right - 8, rect.center.dy));

    verify(() => cubit.showDetails(movieId: 2)).called(1);
  });

  testWidgets('the clear button empties the field', (tester) async {
    final handle = tester.ensureSemantics();
    final cubit = searchCubitMock(resultsState(3));
    await tester.pumpWidget(harnessSearchOverlay(cubit));
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'Batman');
    await tester.pump();

    await tester.tap(find.bySemanticsIdentifier('clearSearchButton'));
    await tester.pump();

    verify(() => cubit.updateSearchQuery('')).called(greaterThan(0));
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, '');
    handle.dispose();
  });

  testWidgets('the clear button only appears once there is text', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      harnessSearchOverlay(searchCubitMock(SearchState.empty())),
    );

    expect(find.bySemanticsIdentifier('clearSearchButton'), findsNothing);

    await tester.enterText(find.byType(TextField), 'B');
    await tester.pump();

    expect(find.bySemanticsIdentifier('clearSearchButton'), findsOne);
    handle.dispose();
  });

  testWidgets('labels the field and the clear button for assistive tech', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      harnessSearchOverlay(searchCubitMock(resultsState(1))),
    );
    await tester.pump();

    expect(find.bySemanticsLabel('Search movies'), findsOne);
    expect(find.bySemanticsLabel('Clear search'), findsOne);

    handle.dispose();
  });

  testWidgets('translates into German', (tester) async {
    await tester.pumpWidget(
      harnessSearchOverlay(
        searchCubitMock(noResultsState()),
        locale: const Locale('de'),
      ),
    );
    await tester.pump();

    expect(find.text('Keine Ergebnisse für „xyzzy“'), findsOne);
    expect(find.text('Versuche es mit einem anderen Suchbegriff'), findsOne);
  });
}
