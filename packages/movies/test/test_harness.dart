//
//  test_harness.dart — the harness the widget and golden tests share
//

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/list/movies_cubit.dart';
import 'package:movies/src/list/movies_list_state.dart';

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
}) {
  GetIt.instance.registerSingleton<MoviesCubit>(cubit);
  return harnessApp(MoviesView(overlay: overlay), locale: locale);
}

Widget harnessApp(Widget child, {Locale? locale}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    locale: locale,
    theme: ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blueAccent,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
    ),
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
