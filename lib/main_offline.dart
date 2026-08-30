//
//  main_offline.dart
//
//  The app with every request failing:
//
//    flutter run -t lib/main_offline.dart
//
//  No key is needed — nothing reaches the network. This is how you get to the
//  failure states: the movies grid's error view and its Retry button, and the
//  search overlay's error view, which must say the search *failed* rather than
//  that it found nothing.
//
//  Change [OfflineNetworkClient.error] to see the other failures — for
//  instance `NetworkError.httpError(500)` or `NetworkError.timeout()`.
//

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:network_service/network_service.dart';

import 'main.dart';
import 'modules.dart';

/// Fails every request with [error], without touching the network.
final class OfflineNetworkClient implements NetworkClient {
  const OfflineNetworkClient({this.error = const NetworkError.noConnection()});

  final Object error;

  @override
  Future<Uint8List> data(Uri url) async => throw error;
}

void main() {
  // Registered before the modules are composed, so `registerNetworkService`
  // leaves the real client out — the same seam the tests use.
  GetIt.instance.registerSingleton<NetworkClient>(
    const OfflineNetworkClient(),
  );
  registerModules();
  runApp(const MoviesDemoApp());
}
