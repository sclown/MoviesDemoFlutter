//
//  test_harness.dart — the harness the widget and golden tests share
//

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:theme/theme.dart';
import 'package:movies/movies.dart';
import 'package:movies_data/movies_data.dart';

/// Emits the states a test hands it and records the calls the view makes.
class MoviesCubitMock extends MockCubit<MoviesListState>
    implements MoviesCubit {}

/// A cubit stuck on [state], or replaying [stream] when one is given.
MoviesCubitMock moviesCubitMock(
  MoviesListState state, {
  Stream<MoviesListState>? stream,
}) {
  final cubit = MoviesCubitMock();
  whenListen(
    cubit,
    stream ?? const Stream<MoviesListState>.empty(),
    initialState: state,
  );
  return cubit;
}

/// Registers [cubit] and returns a `MoviesView` wrapped in the app's theme
/// and localizations.
Widget harnessMoviesView(
  MoviesCubitMock cubit, {
  Widget? overlay,
  Locale? locale,
}) => harnessApp(
  MoviesView(cubit: cubit, overlay: overlay),
  locale: locale,
);

/// Seeds the cache with [movie] and renders its details screen.
Widget harnessDetailsView(MovieDetails movie, {Locale? locale}) => harnessApp(
  DetailsView(movieId: movie.id, cache: MovieCache()..put(movie)),
  locale: locale,
);

/// The details screen for an id the cache never saw.
Widget harnessMissingDetailsView({Locale? locale}) => harnessApp(
  DetailsView(movieId: 999, cache: MovieCache()),
  locale: locale,
);

Widget harnessApp(Widget child, {Locale? locale}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    locale: locale,
    theme: moviesDemoTheme,
    localizationsDelegates: const [
      MoviesLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: MoviesLocalizations.supportedLocales,
    home: child,
  );
}
