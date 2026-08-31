//
//  test_harness.dart — the harness the widget and golden tests share
//

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:theme/theme.dart';
import 'package:search/search.dart';

class SearchCubitMock extends MockCubit<SearchState> implements SearchCubit {}

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
