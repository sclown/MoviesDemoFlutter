//
//  fixtures.dart — canned TMDB payloads and a client that replays them
//

import 'dart:convert';
import 'dart:typed_data';

import 'package:network_service/network_service.dart';

/// Canned TMDB payloads shared by the module tests.
abstract final class Json {
  /// A list of movies with ids `[from, to)`.
  static Uint8List validList({int from = 1, int to = 3, int total = 5}) {
    final list = [
      for (var id = from; id < to; id++)
        '''
        {
            "id": $id,
            "title": "Test Movie $id",
            "overview": "A test movie",
            "poster_path": "/test.jpg",
            "release_date": "2025-01-01",
            "vote_average": 7.5
        }''',
    ].join(', ');
    return _utf8('''
    {
        "results": [$list],
        "total_pages": $total
    }
    ''');
  }

  static Uint8List get singleValid => _utf8('''
    {
        "results": [
            {
                "id": 1,
                "title": "Test Movie 1",
                "overview": "A test movie",
                "poster_path": "/test.jpg",
                "release_date": "2025-01-01",
                "vote_average": 7.5
            }
        ],
        "total_pages": 5
    }
    ''');

  static Uint8List get lowDataList => _utf8('''
    {
        "results": [
            {
                "id": 2,
                "title": "No Poster",
                "overview": "Missing fields",
                "poster_path": null,
                "release_date": null,
                "vote_average": 6.0
            }
        ],
        "total_pages": 1
    }
    ''');

  static Uint8List get invalidDataList => _utf8('''
    {
        "results": [
            {
                "id": 1,
                "overview": "Missing title",
                "vote_average": 5.0
            }
        ],
        "total_pages": 1
    }
    ''');

  /// A list with arbitrary ids, used by the search tests.
  static Uint8List list({required List<int> ids, required int totalPages}) {
    final movies = ids
        .map(
          (id) =>
              '{"id": $id, "title": "Movie $id", "overview": "Overview", '
              '"poster_path": null, "release_date": null, "vote_average": 5.0}',
        )
        .join(',');
    return _utf8('{"results": [$movies], "total_pages": $totalPages}');
  }

  static Uint8List _utf8(String json) =>
      Uint8List.fromList(const Utf8Encoder().convert(json));
}

/// A client that replays a canned result. `result` is mutable so a test can
/// swap the payload between calls (used by the pagination tests).
final class MockNetworkClient implements NetworkClient {
  MockNetworkClient({required this.result});

  MockNetworkClient.success(Uint8List data) : result = Result.success(data);

  MockNetworkClient.failure(Object error) : result = Result.failure(error);

  Result result;

  @override
  Future<Uint8List> data(Uri url) async => result.get();
}

/// Minimal success-or-failure holder for a canned client response.
final class Result {
  const Result.success(Uint8List data) : _data = data, _error = null;

  const Result.failure(Object error) : _data = null, _error = error;

  final Uint8List? _data;
  final Object? _error;

  Uint8List get() {
    final error = _error;
    if (error != null) throw error;
    return _data!;
  }
}
