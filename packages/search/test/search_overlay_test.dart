import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:search/src/empty_search_results_view.dart';
import 'package:search/src/search_result_row.dart';
import 'package:search/src/search_state.dart';

import 'test_harness.dart';

void main() {
  tearDown(GetIt.instance.reset);

  testWidgets('starts as just a search field', (tester) async {
    await tester.pumpWidget(
      harnessSearchOverlay(SearchViewModelMock(SearchState.empty())),
    );

    expect(find.byType(TextField), findsOne);
    expect(find.text('Search'), findsOne);
    expect(find.byType(SearchResultRow), findsNothing);
  });

  testWidgets('typing forwards the query to the view model', (tester) async {
    final viewModel = SearchViewModelMock(SearchState.empty());
    await tester.pumpWidget(harnessSearchOverlay(viewModel));

    await tester.enterText(find.byType(TextField), 'Batman');
    await tester.pump();

    expect(viewModel.queries.last, 'Batman');
  });

  testWidgets('shows the results', (tester) async {
    await tester.pumpWidget(
      harnessSearchOverlay(SearchViewModelMock(SearchState.mockResults(3))),
    );
    await tester.pump();

    expect(find.byType(SearchResultRow), findsNWidgets(3));
    expect(find.text('Test movie 1'), findsOne);
    expect(find.text('7.5'), findsWidgets);
  });

  testWidgets('shows the empty state', (tester) async {
    await tester.pumpWidget(
      harnessSearchOverlay(SearchViewModelMock(SearchState.noResults())),
    );
    await tester.pump();

    expect(find.byType(EmptySearchResultsView), findsOne);
    expect(find.text('No results for "xyzzy"'), findsOne);
    expect(find.text('Try a different search term'), findsOne);
  });

  testWidgets('shows a spinner while searching', (tester) async {
    await tester.pumpWidget(
      harnessSearchOverlay(SearchViewModelMock(SearchState.searching())),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOne);
  });

  testWidgets('tapping a result opens its details', (tester) async {
    final viewModel = SearchViewModelMock(SearchState.mockResults(3));
    await tester.pumpWidget(harnessSearchOverlay(viewModel));
    await tester.pump();

    await tester.tap(find.text('Test movie 2'));

    expect(viewModel.shownDetails, [2]);
  });

  testWidgets('the clear button empties the field', (tester) async {
    final viewModel = SearchViewModelMock(SearchState.mockResults(3));
    await tester.pumpWidget(harnessSearchOverlay(viewModel));
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'Batman');
    await tester.pump();

    await tester.tap(find.byIcon(Icons.cancel));
    await tester.pump();

    expect(viewModel.queries.last, '');
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, '');
  });

  testWidgets('the clear button only appears once there is text', (
    tester,
  ) async {
    await tester.pumpWidget(
      harnessSearchOverlay(SearchViewModelMock(SearchState.empty())),
    );

    expect(find.byIcon(Icons.cancel), findsNothing);

    await tester.enterText(find.byType(TextField), 'B');
    await tester.pump();

    expect(find.byIcon(Icons.cancel), findsOne);
  });

  testWidgets('labels the field and the clear button for assistive tech', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      harnessSearchOverlay(SearchViewModelMock(SearchState.mockResults(1))),
    );
    await tester.pump();

    expect(find.bySemanticsLabel('Search movies'), findsOne);
    expect(find.bySemanticsLabel('Clear search'), findsOne);

    handle.dispose();
  });

  testWidgets('translates into German', (tester) async {
    await tester.pumpWidget(
      harnessSearchOverlay(
        SearchViewModelMock(SearchState.noResults()),
        locale: const Locale('de'),
      ),
    );
    await tester.pump();

    expect(find.text('Keine Ergebnisse für „xyzzy“'), findsOne);
    expect(find.text('Versuche es mit einem anderen Suchbegriff'), findsOne);
  });
}
