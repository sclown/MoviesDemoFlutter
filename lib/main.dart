//
//  main.dart
//

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:movies/movies.dart';
import 'package:search/search.dart';

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
      // Dark only — there is no light variant.
      theme: moviesDemoTheme,
      localizationsDelegates: const [
        MoviesLocalizations.delegate,
        SearchLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: MoviesLocalizations.supportedLocales,
      home: const MoviesView(overlay: SearchOverlay()),
    );
  }
}

/// Shared by the app and the golden tests, so what is asserted is what ships.
final ThemeData moviesDemoTheme = ThemeData(
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
);
