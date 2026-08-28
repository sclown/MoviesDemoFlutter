//
//  test_harness.dart — the harness the widget and golden tests share
//

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:search/search.dart';
import 'package:search/src/search_state.dart';
import 'package:search/src/search_view_model.dart';

/// Publishes whatever state it is handed and records the queries and taps
/// the overlay produces.
final class SearchViewModelMock implements SearchViewModeling {
  SearchViewModelMock(SearchState state) : state = ValueNotifier(state);

  @override
  final ValueNotifier<SearchState> state;

  final queries = <String>[];
  final shownDetails = <int>[];

  @override
  void updateSearchQuery(String query) {
    queries.add(query);
    final current = state.value;
    state.value = SearchState(
      searchResults: current.searchResults,
      isSearching: current.isSearching,
      searchQuery: query,
      showEmptyLabel: current.showEmptyLabel,
    );
  }

  @override
  void showDetails({required int movieId}) => shownDetails.add(movieId);
}

/// The overlay on a black background.
Widget harnessSearchOverlay(SearchViewModelMock viewModel, {Locale? locale}) {
  GetIt.instance.registerSingleton<SearchViewModeling>(viewModel);
  return harnessApp(
    const Scaffold(
      backgroundColor: Colors.black,
      body: SearchOverlay(),
    ),
    locale: locale,
  );
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
    ),
    localizationsDelegates: const [
      SearchLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: SearchLocalizations.supportedLocales,
    home: child,
  );
}
