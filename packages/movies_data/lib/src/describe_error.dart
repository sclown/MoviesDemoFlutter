//
//  describe_error.dart
//

String describeError(Object error) => switch (error) {
  Exception() => error.toString().replaceFirst('Exception: ', ''),
  _ => error.toString(),
};
