//
//  test_harness.dart — the harness the widget and golden tests share
//

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/list/movies_list_state.dart';
import 'package:movies/src/list/movies_view_model.dart';

/// Publishes whatever state it is handed and records the calls the view makes.
final class MoviesViewModelMock implements MoviesViewModeling {
  MoviesViewModelMock(MoviesListState state) : state = ValueNotifier(state);

  @override
  final ValueNotifier<MoviesListState> state;

  final shownDetails = <int>[];
  var loadCount = 0;
  final loadMoreRequests = <int>[];

  @override
  void load() => loadCount++;

  @override
  void loadMoreIfNeeded({required int currentMovieId}) =>
      loadMoreRequests.add(currentMovieId);

  @override
  void showDetails({required int movieId}) => shownDetails.add(movieId);
}

/// Registers [viewModel] and returns a `MoviesView` wrapped in the app's theme
/// and localizations.
Widget harnessMoviesView(
  MoviesViewModelMock viewModel, {
  Widget? overlay,
  Locale? locale,
}) {
  GetIt.instance.registerSingleton<MoviesViewModeling>(viewModel);
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
