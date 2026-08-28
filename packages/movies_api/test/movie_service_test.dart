import 'dart:typed_data';

import 'package:movies_api/mocks.dart';
import 'package:movies_api/movies_api.dart';
import 'package:network_service/mocks.dart';
import 'package:network_service/network_service.dart';
import 'package:test/test.dart';

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
