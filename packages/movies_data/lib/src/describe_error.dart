//
//  describe_error.dart
//

/// The user-facing text for a failure. `NetworkError` already reads as a
/// sentence; anything else falls back to its own `toString`, minus the
/// `Exception: ` prefix Dart prepends.
String describeError(Object error) => switch (error) {
  Exception() => error.toString().replaceFirst('Exception: ', ''),
  _ => error.toString(),
};
