// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'search_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SearchLocalizationsEn extends SearchLocalizations {
  SearchLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get clearSearch => 'Clear search';

  @override
  String noResultsFor(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get search => 'Search';

  @override
  String get searchMovies => 'Search movies';

  @override
  String get tryDifferentTerm => 'Try a different search term';

  @override
  String get searchFailed => 'Search failed';

  @override
  String get dismissSearch => 'Dismiss search';
}
