//
//  network_error.dart
//

import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

sealed class NetworkError implements Exception {
  const NetworkError();

  const factory NetworkError.noConnection() = NoConnection;
  const factory NetworkError.connectionLost() = ConnectionLost;
  const factory NetworkError.timeout() = Timeout;
  const factory NetworkError.httpError(int statusCode) = HttpError;

  String get errorDescription;

  static NetworkError? fromTransportError(Object error) => switch (error) {
    SocketException() => const NetworkError.noConnection(),
    TimeoutException() => const NetworkError.timeout(),
    HandshakeException() => const NetworkError.connectionLost(),
    http.ClientException() when _isConnectionLost(error.message) =>
      const NetworkError.connectionLost(),
    http.ClientException() when _isNoConnection(error.message) =>
      const NetworkError.noConnection(),
    _ => null,
  };

  static bool _isConnectionLost(String message) {
    final lowercased = message.toLowerCase();
    return lowercased.contains('connection closed') ||
        lowercased.contains('connection reset') ||
        lowercased.contains('connection aborted') ||
        lowercased.contains('software caused connection abort');
  }

  static bool _isNoConnection(String message) {
    final lowercased = message.toLowerCase();
    return lowercased.contains('failed host lookup') ||
        lowercased.contains('network is unreachable') ||
        lowercased.contains('connection refused');
  }

  @override
  String toString() => errorDescription;
}

final class NoConnection extends NetworkError {
  const NoConnection();

  @override
  String get errorDescription =>
      'No internet connection. Please check your network settings.';

  @override
  bool operator ==(Object other) => other is NoConnection;

  @override
  int get hashCode => (NoConnection).hashCode;
}

final class ConnectionLost extends NetworkError {
  const ConnectionLost();

  @override
  String get errorDescription => 'The connection was lost. Please try again.';

  @override
  bool operator ==(Object other) => other is ConnectionLost;

  @override
  int get hashCode => (ConnectionLost).hashCode;
}

final class Timeout extends NetworkError {
  const Timeout();

  @override
  String get errorDescription => 'The request timed out. Please try again.';

  @override
  bool operator ==(Object other) => other is Timeout;

  @override
  int get hashCode => (Timeout).hashCode;
}

final class HttpError extends NetworkError {
  const HttpError(this.statusCode);

  final int statusCode;

  @override
  String get errorDescription => 'Server returned an error (HTTP $statusCode).';

  @override
  bool operator ==(Object other) =>
      other is HttpError && other.statusCode == statusCode;

  @override
  int get hashCode => Object.hash(HttpError, statusCode);
}
