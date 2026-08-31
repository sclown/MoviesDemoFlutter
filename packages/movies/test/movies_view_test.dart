import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movies/src/list/movies_list_state.dart';

import 'fixtures.dart';
import 'test_harness.dart';

void main() {
  void usePhoneView(WidgetTester tester) {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  testWidgets('shows the loading state', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      harnessMoviesView(moviesCubitMock(MoviesListState.empty())),
    );

    expect(find.bySemanticsIdentifier('loadingView'), findsOne);
    expect(find.bySemanticsIdentifier('moviesGrid'), findsNothing);
    handle.dispose();
  });

  testWidgets('shows the error state and retries', (tester) async {
    final handle = tester.ensureSemantics();
    final cubit = moviesCubitMock(errorState());
    await tester.pumpWidget(harnessMoviesView(cubit));

    expect(find.bySemanticsIdentifier('errorView'), findsOne);
    expect(find.text('Error'), findsOne);
    // The message is data, not a translation: it has to reach the screen.
    expect(find.text('Some error message'), findsOne);

    await tester.tap(find.bySemanticsIdentifier('retryButton'));

    // Once from initState, once from the button.
    verify(() => cubit.load()).called(2);
    handle.dispose();
  });

  testWidgets('shows a grid of movies', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(harnessMoviesView(moviesCubitMock(loadedState(8))));

    expect(find.bySemanticsIdentifier('moviesGrid'), findsOne);
    expect(find.bySemanticsIdentifier(RegExp(r'^movieCell-')), findsWidgets);
    expect(find.bySemanticsIdentifier('movieCell-1'), findsOne);
    handle.dispose();
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
    final handle = tester.ensureSemantics();
    final states = StreamController<MoviesListState>();
    addTearDown(states.close);
    final cubit = moviesCubitMock(
      MoviesListState.empty(),
      stream: states.stream,
    );
    await tester.pumpWidget(harnessMoviesView(cubit));
    expect(find.bySemanticsIdentifier('loadingView'), findsOne);

    states.add(loadedState(3));
    await tester.pump();

    expect(find.bySemanticsIdentifier('loadingView'), findsNothing);
    expect(find.bySemanticsIdentifier('movieCell-1'), findsOne);
    handle.dispose();
  });

  testWidgets('a fast next page never shows a spinner', (tester) async {
    usePhoneView(tester);
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      harnessMoviesView(moviesCubitMock(loadingMoreState(3))),
    );
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.bySemanticsIdentifier('nextPageSpinner'), findsNothing);
    handle.dispose();
  });

  testWidgets('a slow next page shows one after a second', (tester) async {
    usePhoneView(tester);
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      harnessMoviesView(moviesCubitMock(loadingMoreState(3))),
    );
    await tester.pump(const Duration(milliseconds: 1100));

    expect(find.bySemanticsIdentifier('nextPageSpinner'), findsOne);
    handle.dispose();
  });

  testWidgets('no spinner when no page is in flight', (tester) async {
    usePhoneView(tester);
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(harnessMoviesView(moviesCubitMock(loadedState(3))));
    await tester.pump(const Duration(seconds: 2));

    expect(find.bySemanticsIdentifier('nextPageSpinner'), findsNothing);
    handle.dispose();
  });

  testWidgets('shows the English strings', (tester) async {
    await tester.pumpWidget(
      harnessMoviesView(moviesCubitMock(MoviesListState.empty())),
    );

    expect(find.text('Popular Movies'), findsOne);
    expect(find.text('Loading movies…'), findsOne);
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
