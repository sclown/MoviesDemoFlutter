//
//  theme.dart
//

import 'package:flutter/material.dart';

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
