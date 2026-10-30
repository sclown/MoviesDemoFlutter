//
//  test_harness.dart — the harness the widget and golden tests share
//

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:theme/theme.dart';
import 'package:movies/movies.dart';
import 'package:movies_data/movies_data.dart';

class MoviesCubitMock extends MockCubit<MoviesListState>
    implements MoviesCubit {}

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

class DetailsCubitMock extends MockCubit<DetailsState>
    implements DetailsCubit {}

DetailsCubitMock detailsCubitMock(
  DetailsState state, {
  Stream<DetailsState>? stream,
}) {
  final cubit = DetailsCubitMock();
  whenListen(
    cubit,
    stream ?? const Stream<DetailsState>.empty(),
    initialState: state,
  );
  return cubit;
}

Widget harnessMoviesView(
  MoviesCubitMock cubit, {
  Widget? overlay,
  Locale? locale,
}) => harnessApp(
  MoviesView(cubit: cubit, overlay: overlay),
  locale: locale,
);

/// The details screen showing [movie]. Whether the extra sections appear is
/// decided by whether `movie.extras` is filled in.
Widget harnessDetailsView(
  MovieDetails movie, {
  Locale? locale,
  bool isEnriching = false,
  void Function(Uri url)? onPlayTrailer,
}) => harnessDetailsState(
  DetailsState(movie: movie, isEnriching: isEnriching, errorMessage: null),
  locale: locale,
  onPlayTrailer: onPlayTrailer,
);

Widget harnessDetailsState(
  DetailsState state, {
  Locale? locale,
  Stream<DetailsState>? stream,
  void Function(Uri url)? onPlayTrailer,
}) => harnessApp(
  DetailsView(
    cubit: detailsCubitMock(state, stream: stream),
    onPlayTrailer: onPlayTrailer,
  ),
  locale: locale,
);

/// An id the cache never saw, whose fetch could not find it either.
Widget harnessMissingDetailsView({Locale? locale}) => harnessDetailsState(
  const DetailsState(
    movie: null,
    isEnriching: false,
    errorMessage: 'Not found',
  ),
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
