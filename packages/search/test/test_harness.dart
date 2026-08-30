//
//  test_harness.dart — the harness the widget and golden tests share
//

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:theme/theme.dart';
import 'package:search/search.dart';

/// Emits the states a test hands it and records the calls the overlay makes.
class SearchCubitMock extends MockCubit<SearchState> implements SearchCubit {}

/// A cubit stuck on [state], or replaying [stream] when one is given.
SearchCubitMock searchCubitMock(
  SearchState state, {
  Stream<SearchState>? stream,
}) {
  final cubit = SearchCubitMock();
  whenListen(
    cubit,
    stream ?? const Stream<SearchState>.empty(),
    initialState: state,
  );
  return cubit;
}

/// The overlay on a black background.
Widget harnessSearchOverlay(SearchCubitMock cubit, {Locale? locale}) =>
    harnessApp(
      Scaffold(
        backgroundColor: Colors.black,
        body: SearchOverlay(cubit: cubit),
      ),
      locale: locale,
    );

Widget harnessApp(Widget child, {Locale? locale}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    locale: locale,
    theme: moviesDemoTheme,
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
