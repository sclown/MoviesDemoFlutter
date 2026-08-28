import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:network_service/network_service.dart';
import 'package:test/test.dart';

void main() {
  group('NetworkError.fromTransportError', () {
    test('maps a failed socket to no connection', () {
      final error = NetworkError.fromTransportError(
        const SocketException('failed'),
      );
      expect(error, const NetworkError.noConnection());
    });

    test('maps a failed host lookup to no connection', () {
      final error = NetworkError.fromTransportError(
        http.ClientException('Failed host lookup: api.themoviedb.org'),
      );
      expect(error, const NetworkError.noConnection());
    });

    test('maps a closed connection to connection lost', () {
      final error = NetworkError.fromTransportError(
        http.ClientException('Connection closed before full header was received'),
      );
      expect(error, const NetworkError.connectionLost());
    });

    test('maps a timeout', () {
      final error = NetworkError.fromTransportError(TimeoutException('slow'));
      expect(error, const NetworkError.timeout());
    });

    test('returns null for an unrecognised failure', () {
      final error = NetworkError.fromTransportError(
        const FormatException('nope'),
      );
      expect(error, isNull);
    });
  });

  group('descriptions', () {
    test('no connection', () {
      expect(
        const NetworkError.noConnection().errorDescription,
        'No internet connection. Please check your network settings.',
      );
    });

    test('connection lost', () {
      expect(
        const NetworkError.connectionLost().errorDescription,
        'The connection was lost. Please try again.',
      );
    });

    test('timeout', () {
      expect(
        const NetworkError.timeout().errorDescription,
        'The request timed out. Please try again.',
      );
    });

    test('http error', () {
      expect(
        const NetworkError.httpError(404).errorDescription,
        'Server returned an error (HTTP 404).',
      );
      expect(
        const NetworkError.httpError(500).errorDescription,
        'Server returned an error (HTTP 500).',
      );
    });
  });

  test('http errors compare by status code', () {
    expect(const NetworkError.httpError(401), const NetworkError.httpError(401));
    expect(
      const NetworkError.httpError(401),
      isNot(const NetworkError.httpError(500)),
    );
  });
}
