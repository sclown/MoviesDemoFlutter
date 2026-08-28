// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'movies_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class MoviesLocalizationsEn extends MoviesLocalizations {
  MoviesLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get error => 'Error';

  @override
  String get loadingMovies => 'Loading movies…';

  @override
  String get moviePoster => 'Movie\'s poster';

  @override
  String get popularMovies => 'Popular Movies';

  @override
  String get rating => 'Rating';

  @override
  String releaseDate(String date) {
    return 'Release date: $date';
  }

  @override
  String get retry => 'Retry';
}
