import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:network_service/network_service.dart';
import 'package:test/test.dart';

void main() {
  test('returns the body bytes on success', () async {
    final client = HttpNetworkClient(
      client: MockClient((_) async => http.Response('hello', 200)),
    );

    final data = await client.data(Uri.parse('https://example.com'));

    expect(utf8.decode(data), 'hello');
  });

  test('turns a non-2xx status into an http error', () async {
    final client = HttpNetworkClient(
      client: MockClient((_) async => http.Response('nope', 401)),
    );

    await expectLater(
      client.data(Uri.parse('https://example.com')),
      throwsA(const NetworkError.httpError(401)),
    );
  });

  test('maps a transport failure onto a domain error', () async {
    final client = HttpNetworkClient(
      client: MockClient((_) async {
        throw http.ClientException('Failed host lookup: example.com');
      }),
    );

    await expectLater(
      client.data(Uri.parse('https://example.com')),
      throwsA(const NetworkError.noConnection()),
    );
  });
}
