import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movies/src/list/error_view.dart';
import 'package:movies/src/list/loading_view.dart';
import 'package:movies/src/list/movie_cell.dart';
import 'package:movies/src/list/movies_list_state.dart';

import 'fixtures.dart';
import 'test_harness.dart';

void main() {
  tearDown(GetIt.instance.reset);

  testWidgets('shows the loading state', (tester) async {
    await tester.pumpWidget(
      harnessMoviesView(moviesCubitMock(MoviesListState.empty())),
    );

    expect(find.byType(LoadingView), findsOne);
    expect(find.text('Loading movies…'), findsOne);
    expect(find.text('Popular Movies'), findsOne);
  });

  testWidgets('shows the error state and retries', (tester) async {
    final cubit = moviesCubitMock(errorState());
    await tester.pumpWidget(harnessMoviesView(cubit));

    expect(find.byType(ErrorView), findsOne);
    expect(find.text('Error'), findsOne);
    expect(find.text('Some error message'), findsOne);

    await tester.tap(find.text('Retry'));

    // Once from initState, once from the button.
    verify(() => cubit.load()).called(2);
  });

  testWidgets('shows a grid of movies', (tester) async {
    await tester.pumpWidget(
      harnessMoviesView(moviesCubitMock(loadedState(8))),
    );

    expect(find.byType(MovieCell), findsWidgets);
    expect(find.text('Movie title 1'), findsOne);
  });

  testWidgets('tapping a poster opens its details', (tester) async {
    final cubit = moviesCubitMock(loadedState(3));
    await tester.pumpWidget(harnessMoviesView(cubit));

    await tester.tap(find.text('Movie title 2'));

    verify(() => cubit.showDetails(movieId: 2)).called(1);
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
