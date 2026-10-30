//
//  navigation.dart
//

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:movies/movies.dart';
import 'package:movies_data/movies_data.dart';
import 'package:url_launcher/url_launcher.dart';

final navigatorKey = GlobalKey<NavigatorState>();

final class AppNavigator implements MovieNavigator {
  const AppNavigator(this._getIt);
  final GetIt _getIt;

  @override
  void navigate(int movieId) => navigatorKey.currentState?.push(
    MaterialPageRoute<void>(
      builder: (_) => DetailsView(
        cubit: _getIt<DetailsCubit>(param1: movieId),
        onPlayTrailer: playTrailer,
      ),
    ),
  );
}

/// Hands a trailer to whatever handles YouTube links on this device — the app
/// if it is installed, the browser otherwise. The movies module takes this as
/// a callback so it needs no launcher dependency of its own.
Future<void> playTrailer(Uri url) async {
  await launchUrl(url, mode: LaunchMode.externalApplication);
}
