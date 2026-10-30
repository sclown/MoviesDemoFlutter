// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'movies_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class MoviesLocalizationsDe extends MoviesLocalizations {
  MoviesLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get error => 'Fehler';

  @override
  String get loadingMovies => 'Filme werden geladen…';

  @override
  String get moviePoster => 'Filmplakat';

  @override
  String get popularMovies => 'Beliebte Filme';

  @override
  String get rating => 'Bewertung';

  @override
  String releaseDate(String date) {
    return 'Erscheinungsdatum: $date';
  }

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get movieUnavailable => 'Dieser Film ist nicht mehr verfügbar.';

  @override
  String get cast => 'Besetzung';

  @override
  String get crew => 'Stab';

  @override
  String get trailers => 'Trailer';

  @override
  String playTrailer(String name) {
    return 'Trailer $name abspielen';
  }
}
