//
//  modules_test.dart — the composed dependency graph
//

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:movies_api/movies_api.dart';
import 'package:movies_core/movies_core.dart';
import 'package:movies_demo_flutter/modules.dart';
import 'package:movies_demo_flutter/navigation.dart';
import 'package:network_service/network_service.dart';

void main() {
  tearDown(GetIt.instance.reset);

  test('registers the whole graph', () {
    registerModules();

    expect(GetIt.instance<NetworkClient>(), isA<HttpNetworkClient>());
    expect(GetIt.instance<MovieServicing>(), isA<MovieService>());
    expect(GetIt.instance<MovieNavigator>(), isA<AppNavigator>());
    expect(GetIt.instance<MovieCache>(), isA<MovieCache>());
  });

  test('the service is a singleton', () {
    registerModules();

    expect(
      GetIt.instance<MovieServicing>(),
      same(GetIt.instance<MovieServicing>()),
    );
  });

  test('the navigator is the router-backed one, not the no-op default', () {
    registerModules();

    expect(GetIt.instance<MovieNavigator>(), isA<AppNavigator>());
  });

  test('a stub registered first still wins', () {
    // How the app test swaps the graph: register before composing.
    GetIt.instance.registerSingleton<MovieNavigator>(_StubNavigator());
    registerModules();

    expect(GetIt.instance<MovieNavigator>(), isA<_StubNavigator>());
  });
}

final class _StubNavigator implements MovieNavigator {
  @override
  void navigate(int movieId) {}
}
