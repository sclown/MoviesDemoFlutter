import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:movies/src/list/error_view.dart';
import 'package:movies/src/list/loading_view.dart';
import 'package:movies/src/list/movie_cell.dart';
import 'package:movies/src/list/movies_list_state.dart';

import 'test_harness.dart';

void main() {
  tearDown(GetIt.instance.reset);

  testWidgets('shows the loading state', (tester) async {
    await tester.pumpWidget(
      harnessMoviesView(MoviesViewModelMock(MoviesListState.empty())),
    );

    expect(find.byType(LoadingView), findsOne);
    expect(find.text('Loading movies…'), findsOne);
    expect(find.text('Popular Movies'), findsOne);
  });

  testWidgets('shows the error state and retries', (tester) async {
    final viewModel = MoviesViewModelMock(MoviesListState.error());
    await tester.pumpWidget(harnessMoviesView(viewModel));

    expect(find.byType(ErrorView), findsOne);
    expect(find.text('Error'), findsOne);
    expect(find.text('Some error message'), findsOne);

    await tester.tap(find.text('Retry'));

    // Once from initState, once from the button.
    expect(viewModel.loadCount, 2);
  });

  testWidgets('shows a grid of movies', (tester) async {
    await tester.pumpWidget(
      harnessMoviesView(MoviesViewModelMock(MoviesListState.mockMovies(8))),
    );

    expect(find.byType(MovieCell), findsWidgets);
    expect(find.text('Movie title 1'), findsOne);
  });

  testWidgets('tapping a poster opens its details', (tester) async {
    final viewModel = MoviesViewModelMock(MoviesListState.mockMovies(3));
    await tester.pumpWidget(harnessMoviesView(viewModel));

    await tester.tap(find.text('Movie title 2'));

    expect(viewModel.shownDetails, [2]);
  });

  testWidgets('asks for the next page once the last cell is built', (
    tester,
  ) async {
    final viewModel = MoviesViewModelMock(MoviesListState.mockMovies(3));
    await tester.pumpWidget(harnessMoviesView(viewModel));
    await tester.pump();

    expect(viewModel.loadMoreRequests, [3]);
  });

  testWidgets('loads on first build', (tester) async {
    final viewModel = MoviesViewModelMock(MoviesListState.mockMovies(3));
    await tester.pumpWidget(harnessMoviesView(viewModel));

    expect(viewModel.loadCount, 1);
  });

  testWidgets('rebuilds when the state changes', (tester) async {
    final viewModel = MoviesViewModelMock(MoviesListState.empty());
    await tester.pumpWidget(harnessMoviesView(viewModel));
    expect(find.byType(LoadingView), findsOne);

    viewModel.state.value = MoviesListState.mockMovies(3);
    await tester.pump();

    expect(find.byType(LoadingView), findsNothing);
    expect(find.text('Movie title 1'), findsOne);
  });

  testWidgets('translates into German', (tester) async {
    await tester.pumpWidget(
      harnessMoviesView(
        MoviesViewModelMock(MoviesListState.empty()),
        locale: const Locale('de'),
      ),
    );

    expect(find.text('Beliebte Filme'), findsOne);
    expect(find.text('Filme werden geladen…'), findsOne);
  });
}
