//
//  mocks.dart — JSON fixtures shared by the module tests
//

import 'dart:convert';
import 'dart:typed_data';

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
