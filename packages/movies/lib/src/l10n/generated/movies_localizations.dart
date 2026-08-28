import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'movies_localizations_de.dart';
import 'movies_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of MoviesLocalizations
/// returned by `MoviesLocalizations.of(context)`.
///
/// Applications need to include `MoviesLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/movies_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: MoviesLocalizations.localizationsDelegates,
///   supportedLocales: MoviesLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the MoviesLocalizations.supportedLocales
/// property.
abstract class MoviesLocalizations {
  MoviesLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static MoviesLocalizations of(BuildContext context) {
    return Localizations.of<MoviesLocalizations>(context, MoviesLocalizations)!;
  }

  static const LocalizationsDelegate<MoviesLocalizations> delegate =
      _MoviesLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// Title of the error state shown when movies fail to load.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Progress indicator label while the movies list is loading.
  ///
  /// In en, this message translates to:
  /// **'Loading movies…'**
  String get loadingMovies;

  /// Accessibility label for the movie poster image on the details screen.
  ///
  /// In en, this message translates to:
  /// **'Movie\'s poster'**
  String get moviePoster;

  /// Navigation bar title on the popular movies screen.
  ///
  /// In en, this message translates to:
  /// **'Popular Movies'**
  String get popularMovies;

  /// Accessibility label for the rating value on the details screen.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// Release date line on the details screen.
  ///
  /// In en, this message translates to:
  /// **'Release date: {date}'**
  String releaseDate(String date);

  /// Button that re-attempts loading after an error.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;
}

class _MoviesLocalizationsDelegate
    extends LocalizationsDelegate<MoviesLocalizations> {
  const _MoviesLocalizationsDelegate();

  @override
  Future<MoviesLocalizations> load(Locale locale) {
    return SynchronousFuture<MoviesLocalizations>(
      lookupMoviesLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_MoviesLocalizationsDelegate old) => false;
}

MoviesLocalizations lookupMoviesLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return MoviesLocalizationsDe();
    case 'en':
      return MoviesLocalizationsEn();
  }

  throw FlutterError(
    'MoviesLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
