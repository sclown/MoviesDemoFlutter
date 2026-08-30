//
//  main_slow.dart
//
//  The app against a deliberately slow network:
//
//    flutter run -t lib/main_slow.dart --dart-define-from-file=.env.local
//
//  Every request takes a second longer than it should, which is how you get to
//  see the states that are otherwise too quick to catch: the initial spinner,
//  the next-page spinner in the grid footer, and the search debounce.
//

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:network_service/network_service.dart';

import 'main.dart';
import 'modules.dart';

/// Wraps another client and makes every request take [delay] longer.
final class SlowNetworkClient implements NetworkClient {
  SlowNetworkClient(this._inner, {this.delay = const Duration(seconds: 2)});

  final NetworkClient _inner;
  final Duration delay;

  @override
  Future<Uint8List> data(Uri url) async {
    await Future<void>.delayed(delay);
    return _inner.data(url);
  }
}

void main() {
  GetIt.instance.registerSingleton<NetworkClient>(
    SlowNetworkClient(HttpNetworkClient()),
  );
  registerModules();
  runApp(const MoviesDemoApp());
}
