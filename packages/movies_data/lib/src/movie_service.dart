//
//  movie_service.dart
//

import 'dart:io' show Platform;

import 'package:get_it/get_it.dart';
import 'package:network_service/network_service.dart';

import 'dtos/movie.dart';
import 'dtos/movie_detail.dart';
import 'movie_parser.dart';

abstract interface class MovieServicing {
  Future<MovieResponse> fetchPopularMovies({required int page});
  Future<MovieResponse> searchMovies({required String query, int page = 1});

  /// The full record for one movie, credits and videos included.
  Future<MovieDetailResponse> fetchMovie({required int id});
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

  @override
  Future<MovieDetailResponse> fetchMovie({required int id}) async {
    final url = _makeUrl(
      path: '/movie/$id',
      queryItems: {
        // TMDB resolves each of these sub-resources server-side and merges it
        // into the movie object, so this stays a single round trip.
        'append_to_response': 'credits,videos',
        'include_video_language': _videoLanguages(),
      },
    );
    final data = await _networkClient.data(url);
    return _parser.parseMovieDetail(data);
  }

  /// `language` filters appended videos rather than falling back, so a movie
  /// with no German trailer would come back with none at all. Naming English
  /// and the untagged uploads as well keeps the trailer row populated in every
  /// locale.
  String _videoLanguages() {
    final primary = _language().split('-').first;
    return primary == 'en' ? 'en,null' : '$primary,en,null';
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
