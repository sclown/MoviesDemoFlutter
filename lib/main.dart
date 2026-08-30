//
//  main.dart
//

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:movies/movies.dart';
import 'package:search/search.dart';
import 'package:theme/theme.dart';

import 'modules.dart';
import 'navigation.dart';

void main() {
  registerModules();
  runApp(const MoviesDemoApp());
}

class MoviesDemoApp extends StatelessWidget {
  const MoviesDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Movies',
      debugShowCheckedModeBanner: false,
      theme: moviesDemoTheme,
      localizationsDelegates: const [
        MoviesLocalizations.delegate,
        SearchLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: MoviesLocalizations.supportedLocales,
      home: MoviesView(
        cubit: GetIt.instance<MoviesCubit>(),
        overlay: SearchOverlay(cubit: GetIt.instance<SearchCubit>()),
      ),
    );
  }
}
