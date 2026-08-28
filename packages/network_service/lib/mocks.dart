//
//  mocks.dart — network_service test doubles
//

import 'dart:typed_data';

import 'network_service.dart';

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
