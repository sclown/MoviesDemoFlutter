//
//  main_view_model.dart
//

import 'package:flutter/foundation.dart';
import 'package:movies_core/movies_core.dart';

/// Owns the navigation stack. Features push onto it through [MovieNavigator],
/// so they never reach for a `Navigator` of their own.
final class MainViewModel extends ChangeNotifier implements MovieNavigator {
  List<MovieDetails> _path = const [];

  List<MovieDetails> get path => List.unmodifiable(_path);

  @override
  void navigate(MovieDetails movie) {
    _path = [..._path, movie];
    notifyListeners();
  }

  void reset(List<MovieDetails> path) {
    _path = List.of(path);
    notifyListeners();
  }
}
