//
//  theme.dart
//

import 'package:flutter/material.dart';

/// The one definition of how the app looks. The golden tests render against
/// this too, so what they assert is what ships.
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
