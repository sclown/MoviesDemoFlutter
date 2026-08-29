import 'package:flutter_test/flutter_test.dart';
import 'package:main_navigation/main_navigation.dart';
import 'package:movies_core_mocks/movies_core_mocks.dart';

void main() {
  test('the initial path is empty', () {
    expect(MainViewModel().path, isEmpty);
  });

  test('navigate appends to the path', () {
    final vm = MainViewModel();

    vm.navigate(movieDetails());

    expect(vm.path, hasLength(1));
    expect(vm.path.first.id, 1);
  });

  test('navigate notifies listeners', () {
    final vm = MainViewModel();
    var notifications = 0;
    vm.addListener(() => notifications++);

    vm.navigate(movieDetails());

    expect(notifications, 1);
  });

  test('reset clears the path', () {
    final vm = MainViewModel();

    vm.navigate(movieDetails(id: 1));
    vm.reset(const []);

    expect(vm.path, isEmpty);
  });

  test('the path is not mutable from the outside', () {
    final vm = MainViewModel();
    vm.navigate(movieDetails());

    expect(() => vm.path.add(movieDetails(id: 2)), throwsUnsupportedError);
  });
}
