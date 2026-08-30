import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movies/src/list/error_view.dart';
import 'package:movies/src/list/loading_view.dart';
import 'package:movies/src/list/movie_cell.dart';
import 'package:movies/src/list/movies_list_state.dart';

import 'fixtures.dart';
import 'test_harness.dart';

void main() {
  /// The default 800x600 test view is shorter than one grid row, so the
  /// footer below the grid is never built. These use a phone-sized view.
  void usePhoneView(WidgetTester tester) {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  testWidgets('shows the loading state', (tester) async {
    await tester.pumpWidget(
      harnessMoviesView(moviesCubitMock(MoviesListState.empty())),
    );

    expect(find.byType(LoadingView), findsOne);
    expect(find.text('Loading movies…'), findsOne);
    expect(find.text('Popular Movies'), findsOne);
  });

  testWidgets('shows the error state and retries', (tester) async {
    final handle = tester.ensureSemantics();
    final cubit = moviesCubitMock(errorState());
    await tester.pumpWidget(harnessMoviesView(cubit));

    expect(find.byType(ErrorView), findsOne);
    expect(find.text('Error'), findsOne);
    expect(find.text('Some error message'), findsOne);

    await tester.tap(find.bySemanticsIdentifier('retryButton'));

    // Once from initState, once from the button.
    verify(() => cubit.load()).called(2);
    handle.dispose();
  });

  testWidgets('shows a grid of movies', (tester) async {
    await tester.pumpWidget(
      harnessMoviesView(moviesCubitMock(loadedState(8))),
    );

    expect(find.byType(MovieCell), findsWidgets);
    expect(find.text('Movie title 1'), findsOne);
  });

  testWidgets('tapping a poster opens its details', (tester) async {
    final handle = tester.ensureSemantics();
    final cubit = moviesCubitMock(loadedState(3));
    await tester.pumpWidget(harnessMoviesView(cubit));

    await tester.tap(find.bySemanticsIdentifier('movieCell-2'));

    verify(() => cubit.showDetails(movieId: 2)).called(1);
    handle.dispose();
  });

  testWidgets('asks for the next page once the last cell is built', (
    tester,
  ) async {
    final cubit = moviesCubitMock(loadedState(3));
    await tester.pumpWidget(harnessMoviesView(cubit));
    await tester.pump();

    verify(() => cubit.loadMoreIfNeeded(currentMovieId: 3)).called(1);
  });

  testWidgets('loads on first build', (tester) async {
    final cubit = moviesCubitMock(loadedState(3));
    await tester.pumpWidget(harnessMoviesView(cubit));

    verify(() => cubit.load()).called(1);
  });

  testWidgets('rebuilds when the state changes', (tester) async {
    final states = StreamController<MoviesListState>();
    addTearDown(states.close);
    final cubit = moviesCubitMock(
      MoviesListState.empty(),
      stream: states.stream,
    );
    await tester.pumpWidget(harnessMoviesView(cubit));
    expect(find.byType(LoadingView), findsOne);

    states.add(loadedState(3));
    await tester.pump();

    expect(find.byType(LoadingView), findsNothing);
    expect(find.text('Movie title 1'), findsOne);
  });

  testWidgets('a fast next page never shows a spinner', (tester) async {
    usePhoneView(tester);
    await tester.pumpWidget(harnessMoviesView(moviesCubitMock(loadingMoreState(3))));
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('a slow next page shows one after a second', (tester) async {
    usePhoneView(tester);
    await tester.pumpWidget(harnessMoviesView(moviesCubitMock(loadingMoreState(3))));
    await tester.pump(const Duration(milliseconds: 1100));

    expect(find.byType(CircularProgressIndicator), findsOne);
  });

  testWidgets('no spinner when no page is in flight', (tester) async {
    usePhoneView(tester);
    await tester.pumpWidget(harnessMoviesView(moviesCubitMock(loadedState(3))));
    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('translates into German', (tester) async {
    await tester.pumpWidget(
      harnessMoviesView(
        moviesCubitMock(MoviesListState.empty()),
        locale: const Locale('de'),
      ),
    );

    expect(find.text('Beliebte Filme'), findsOne);
    expect(find.text('Filme werden geladen…'), findsOne);
  });
}
