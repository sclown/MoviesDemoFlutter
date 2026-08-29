// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'search_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class SearchLocalizationsDe extends SearchLocalizations {
  SearchLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get clearSearch => 'Suche löschen';

  @override
  String noResultsFor(String query) {
    return 'Keine Ergebnisse für „$query“';
  }

  @override
  String get search => 'Suchen';

  @override
  String get searchMovies => 'Filme suchen';

  @override
  String get tryDifferentTerm => 'Versuche es mit einem anderen Suchbegriff';

  @override
  String get searchFailed => 'Suche fehlgeschlagen';
}
