//
//  movies_data_mock.dart
//

import 'package:mocktail/mocktail.dart';
import 'package:movies_data/movies_data.dart';

/// Records the calls a cubit makes and answers with whatever the test stubbed.
class MoviesApiMock extends Mock implements MovieServicing {}
