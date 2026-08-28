import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:movies_core/movies_core.dart';

void main() {
  tearDown(GetIt.instance.reset);

  test('registers the no-op navigator by default', () {
    registerMoviesCore();

    expect(GetIt.instance<MovieNavigator>(), isA<NoopNavigator>());
  });

  test('leaves an existing registration alone', () {
    GetIt.instance.registerSingleton<MovieNavigator>(_RecordingNavigator());

    registerMoviesCore();

    expect(GetIt.instance<MovieNavigator>(), isA<_RecordingNavigator>());
  });
}

final class _RecordingNavigator implements MovieNavigator {
  final visited = <MovieDetails>[];

  @override
  void navigate(MovieDetails movie) => visited.add(movie);
}
