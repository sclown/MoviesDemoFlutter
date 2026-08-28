import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:main_navigation/main_navigation.dart';
import 'package:movies_api/movies_api.dart';
import 'package:movies_core/movies_core.dart';
import 'package:network_service/network_service.dart';

void main() {
  tearDown(GetIt.instance.reset);

  test('registers the whole graph', () {
    registerModules();

    expect(GetIt.instance<NetworkClient>(), isA<HttpNetworkClient>());
    expect(GetIt.instance<MovieServicing>(), isA<MovieService>());
    expect(GetIt.instance<MovieNavigator>(), isA<MainViewModel>());
  });

  test('the service is a singleton', () {
    registerModules();

    expect(
      GetIt.instance<MovieServicing>(),
      same(GetIt.instance<MovieServicing>()),
    );
  });

  test('the navigator is the view model that drives the stack', () {
    registerModules();

    expect(GetIt.instance<MovieNavigator>(), same(GetIt.instance<MainViewModel>()));
  });
}
