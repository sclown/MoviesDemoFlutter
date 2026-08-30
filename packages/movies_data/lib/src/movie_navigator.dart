//
//  movie_navigator.dart
//

/// Feature modules depend on this, never on each other, so `movies` and
/// `search` stay independent of where a tap actually leads. Only the app
/// implements it.
abstract interface class MovieNavigator {
  void navigate(int movieId);
}
