//
//  movie_service.dart
//

import 'dart:io' show Platform;

import 'package:get_it/get_it.dart';
import 'package:network_service/network_service.dart';

import 'dtos/movie.dart';
import 'movie_parser.dart';

abstract interface class MovieServicing {
  Future<MovieResponse> fetchPopularMovies({required int page});
  Future<MovieResponse> searchMovies({required String query, int page = 1});
}

void registerMoviesApi({GetIt? container, String Function()? language}) {
  final getIt = container ?? GetIt.instance;
  if (!getIt.isRegistered<MovieServicing>()) {
    getIt.registerLazySingleton<MovieServicing>(
      () => MovieService(
        networkClient: getIt<NetworkClient>(),
        language: language,
      ),
    );
  }
}

final class MovieService implements MovieServicing {
  MovieService({
    required NetworkClient networkClient,
    MovieParser parser = const MovieParser(),
    String? apiKey,
    String Function()? language,
  }) : _networkClient = networkClient,
       _parser = parser,
       _apiKey = apiKey ?? resolveApiKey(),
       _language = language ?? _defaultLanguage;

  static const _baseUrl = 'https://api.themoviedb.org/3';

  final NetworkClient _networkClient;
  final MovieParser _parser;
  final String _apiKey;

  final String Function() _language;

  static String _defaultLanguage() => 'en-US';

  static String resolveApiKey() {
    const compiled = String.fromEnvironment('TMDB_API_KEY');
    if (compiled.isNotEmpty) return compiled;
    return Platform.environment['TMDB_API_KEY'] ?? '';
  }

  @override
  Future<MovieResponse> fetchPopularMovies({required int page}) async {
    final url = _makeUrl(path: '/movie/popular', queryItems: {'page': '$page'});
    final data = await _networkClient.data(url);
    return _parser.parseMovieResponse(data);
  }

  @override
  Future<MovieResponse> searchMovies({
    required String query,
    int page = 1,
  }) async {
    final url = _makeUrl(
      path: '/search/movie',
      queryItems: {'query': query, 'page': '$page'},
    );
    final data = await _networkClient.data(url);
    return _parser.parseMovieResponse(data);
  }

  Uri _makeUrl({
    required String path,
    Map<String, String> queryItems = const {},
  }) => Uri.parse('$_baseUrl$path').replace(
    queryParameters: {
      'api_key': _apiKey,
      'language': _language(),
      ...queryItems,
    },
  );
}
