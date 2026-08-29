//
//  network_client.dart
//

import 'dart:typed_data';

import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import 'network_error.dart';

/// Loads raw bytes for a URL. The single seam every higher layer mocks.
abstract interface class NetworkClient {
  Future<Uint8List> data(Uri url);
}

/// Registers the default client. Call once at start-up; tests override the
/// registration instead of injecting through constructors.
void registerNetworkService({GetIt? container}) {
  final getIt = container ?? GetIt.instance;
  if (!getIt.isRegistered<NetworkClient>()) {
    getIt.registerLazySingleton<NetworkClient>(HttpNetworkClient.new);
  }
}

final class HttpNetworkClient implements NetworkClient {
  HttpNetworkClient({
    http.Client? client,
    this.timeout = const Duration(seconds: 30),
  }) : _client = client ?? http.Client();

  final http.Client _client;

  /// Without this a stalled request hangs until the OS gives up, and
  /// [NetworkError.timeout] is unreachable.
  final Duration timeout;

  @override
  Future<Uint8List> data(Uri url) async {
    try {
      final response = await _client.get(url).timeout(timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw NetworkError.httpError(response.statusCode);
      }
      return response.bodyBytes;
    } on NetworkError {
      rethrow;
    } catch (error) {
      throw NetworkError.fromTransportError(error) ?? error;
    }
  }
}
