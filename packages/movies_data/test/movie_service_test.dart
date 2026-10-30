import 'dart:typed_data';

import 'package:movies_data/movies_data.dart';
import 'package:network_service/network_service.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  test('fetch returns movies', () async {
    final client = MockNetworkClient.success(Json.singleValid);
    final service = MovieService(networkClient: client, apiKey: 'test-key');

    final response = await service.fetchPopularMovies(page: 1);

    expect(response.results, hasLength(1));
    expect(response.results[0].title, 'Test Movie 1');
  });

  test('fetch propagates a network error', () async {
    final client = MockNetworkClient.failure(const NetworkError.noConnection());
    final service = MovieService(networkClient: client, apiKey: 'test-key');

    await expectLater(
      service.fetchPopularMovies(page: 1),
      throwsA(isA<NetworkError>()),
    );
  });

  test('fetch propagates a parse error', () async {
    final client = MockNetworkClient.success(Json.invalidDataList);
    final service = MovieService(networkClient: client, apiKey: 'test-key');

    await expectLater(
      service.fetchPopularMovies(page: 1),
      throwsA(isA<Object>()),
    );
  });

  test('search sends the query, page, key and language', () async {
    final client = _RecordingClient(Json.singleValid);
    final service = MovieService(networkClient: client, apiKey: 'test-key');

    await service.searchMovies(query: 'Batman', page: 2);

    final url = client.lastUrl!;
    expect(url.path, '/3/search/movie');
    expect(url.queryParameters['query'], 'Batman');
    expect(url.queryParameters['page'], '2');
    expect(url.queryParameters['api_key'], 'test-key');
    expect(url.queryParameters['language'], 'en-US');
  });

  test('search defaults to the first page', () async {
    final client = _RecordingClient(Json.singleValid);
    final service = MovieService(networkClient: client, apiKey: 'test-key');

    await service.searchMovies(query: 'Batman');

    expect(client.lastUrl!.queryParameters['page'], '1');
  });

  test('the language comes from the caller and is read per request', () async {
    var tag = 'de-DE';
    final client = _RecordingClient(Json.singleValid);
    final service = MovieService(
      networkClient: client,
      apiKey: 'test-key',
      language: () => tag,
    );

    await service.fetchPopularMovies(page: 1);
    expect(client.lastUrl!.queryParameters['language'], 'de-DE');

    // A locale change mid-session reaches the next request.
    tag = 'en-US';
    await service.fetchPopularMovies(page: 1);
    expect(client.lastUrl!.queryParameters['language'], 'en-US');
  });

  test('fetching one movie appends its credits and videos', () async {
    final client = _RecordingClient(Json.movieDetail);
    final service = MovieService(networkClient: client, apiKey: 'test-key');

    await service.fetchMovie(id: 42);

    final url = client.lastUrl!;
    expect(url.path, '/3/movie/42');
    expect(url.queryParameters['append_to_response'], 'credits,videos');
    expect(url.queryParameters['api_key'], 'test-key');
  });

  test('fetching one movie returns the appended resources', () async {
    final client = MockNetworkClient.success(Json.movieDetail);
    final service = MovieService(networkClient: client, apiKey: 'test-key');

    final detail = await service.fetchMovie(id: 42);

    expect(detail.genres, hasLength(2));
    expect(detail.cast, hasLength(2));
    expect(detail.crew, hasLength(1));
  });

  test(
    'a non-English locale still asks for English and untagged videos',
    () async {
      final client = _RecordingClient(Json.movieDetail);
      final service = MovieService(
        networkClient: client,
        apiKey: 'test-key',
        language: () => 'de-DE',
      );

      await service.fetchMovie(id: 42);

      // `language` filters appended videos rather than falling back, so a movie
      // with no German trailer would otherwise come back with none at all.
      expect(
        client.lastUrl!.queryParameters['include_video_language'],
        'de,en,null',
      );
    },
  );

  test('an English locale does not ask for English twice', () async {
    final client = _RecordingClient(Json.movieDetail);
    final service = MovieService(networkClient: client, apiKey: 'test-key');

    await service.fetchMovie(id: 42);

    expect(
      client.lastUrl!.queryParameters['include_video_language'],
      'en,null',
    );
  });

  test('fetching one movie propagates a network error', () async {
    final client = MockNetworkClient.failure(const NetworkError.noConnection());
    final service = MovieService(networkClient: client, apiKey: 'test-key');

    await expectLater(service.fetchMovie(id: 42), throwsA(isA<NetworkError>()));
  });
}

/// Captures the URL the service builds so the query can be asserted.
final class _RecordingClient implements NetworkClient {
  _RecordingClient(this._payload);

  final Uint8List _payload;
  Uri? lastUrl;

  @override
  Future<Uint8List> data(Uri url) async {
    lastUrl = url;
    return _payload;
  }
}
