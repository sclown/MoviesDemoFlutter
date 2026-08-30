# MoviesDemoFlutter

Browse and search movies using the
[The Movie Database (TMDB)](https://www.themoviedb.org) API.

## Features

- **Popular Movies** — a two-column poster grid with infinite-scroll pagination
  that de-duplicates overlapping TMDB pages.
- **Search** — a bottom search bar that dims the screen and shows live results,
  with a 500 ms debounce and stale-response cancellation.
- **Details** — poster, star rating, release date and overview.
- English and German, localized per feature module.
- Dark theme only.

## Getting started

### 1. Get a TMDB API key

1. Create a free account at [themoviedb.org](https://www.themoviedb.org/signup).
2. Go to **Settings → API** ([direct link](https://www.themoviedb.org/settings/api))
   and request an API key (the "Developer" option is free).
3. Copy your **API Key (v3 auth)** — a 32-character string.

### 2. Provide the key without committing it

The key never lives in the repository. Copy the example file and fill it in —
`.env.local` is gitignored, so your key stays on your machine:

```bash
cp .env.local.example .env.local
$EDITOR .env.local          # TMDB_API_KEY=your-32-char-key
flutter run --dart-define-from-file=.env.local
```

`--dart-define-from-file` is built into Flutter — no `dotenv` package involved.
It reads `.env` (and `.json`) files and exposes each entry to
`String.fromEnvironment`. The bundled `.vscode/launch.json` already passes the
flag, so **Run** in VS Code needs nothing extra, and `.vscode/settings.json`
passes it to test runs too; in Android Studio put
`--dart-define-from-file=.env.local` under *Additional run args*.

Because of that settings entry, **`.env.local` must exist before running any
test from VS Code** — the flag is a hard error when the file is missing, even
for the unit tests that don't need a key.

Two alternatives work as well, and take precedence in this order:

```bash
flutter run --dart-define=TMDB_API_KEY=your-32-char-key   # wins over the file
export TMDB_API_KEY=your-32-char-key && flutter run       # process environment
```

The process environment is the fallback `MovieService.resolveApiKey` checks
last, which is what lets `dart test` and `flutter test` pick up an exported
variable with no flags.

If none of the three is set, requests are sent with an empty key and TMDB
returns an authentication error, which surfaces as the error state with a
**Retry** button.

> A key handed to the app this way is baked into the binary and can be read back
> out of it. It keeps the key out of version control, not out of the shipped app.

## Alternative entry points

`lib/main.dart` is the app. `lib/main_slow.dart` builds the same app over a
network client that adds a second to every request, which is the only
comfortable way to look at the states that are otherwise too quick to catch —
the initial spinner, the next-page spinner in the grid footer, and the search
debounce:

```bash
flutter run -t lib/main_slow.dart --dart-define-from-file=.env.local
```

`lib/main_offline.dart` fails every request instead, which is how you reach the
error states — the grid's Retry button, and the search overlay's error view.
It needs no key, since nothing leaves the process:

```bash
flutter run -t lib/main_offline.dart
```

Both work by registering their own `NetworkClient` before `registerModules()`,
which leaves the real one out — the same seam the tests use. VS Code has
matching *(slow network)* and *(offline)* launch configurations.

## Architecture

A [pub workspace](https://dart.dev/tools/pub/workspaces) of Dart packages, so a
module can only reach what it declares in its `pubspec.yaml`.

| Package | Responsibility |
|---|---|
| `packages/network_service` | `NetworkClient` seam over `package:http`, plus the domain-level `NetworkError`s. |
| `packages/movies_data` | TMDB DTOs and parsing, `MovieService`, and the domain types the features share — `MovieDetails`, `MovieCache`, the `MovieNavigator` seam. |
| `packages/theme` | The app's `ThemeData`. One definition, used by the app and the golden tests. |
| `packages/movies` | The popular-movies grid and the details screen. |
| `packages/search` | The search overlay. |
| `packages/movies_data_mocks` | A `MovieServicing` mock and the values it returns. |
| `lib/` | The route table, the dependency graph, the theme and the entry point. |

The feature modules never import one another. `movies` and `search` depend on
the `MovieNavigator` interface in `movies_data`; `lib/` is the only place that
knows every module exists.

`movies_data_mocks` is a `dev_dependency` only, so nothing in it reaches a
shipped binary, and `movies_data` cannot reach it, so there is no dependency
cycle. `movies_data`'s own JSON fixtures and fake client are local to
`packages/movies_data/test/fixtures.dart`, since nothing outside that package
needs them.

- **State management** — each feature owns a
  [`Cubit`](https://pub.dev/packages/flutter_bloc) publishing one immutable
  state value, which the views render through `BlocBuilder`. The state classes
  implement `==`, so re-emitting an unchanged state is not a rebuild.
- **Dependency injection** — [`get_it`](https://pub.dev/packages/get_it). Each
  module exposes a `register…()` that skips anything already registered, so
  tests substitute a mock simply by registering first. Only `lib/` reads from
  the container: the widgets take their cubit or cache through the
  constructor, so a widget test constructs one directly and never touches
  `get_it`.
- **Navigation** — Flutter's own `Navigator`, driven from `lib/navigation.dart`
  through a `GlobalKey<NavigatorState>` so a cubit can push without a
  `BuildContext`. Features push a movie *id* through the `MovieNavigator`
  abstraction, so only the app knows that opening a movie means showing
  `DetailsView`; the modules stay unaware of each other and of the
  destinations. There is no routing package: the app has one push, and deep
  links would need `MovieCache` to be fillable from the network first.
- **Details data** — the list and search screens write what they load into
  `MovieCache`, and the details screen renders straight out of it by id. That
  keeps the route free of any attached object, so nothing can be dropped
  between the push and the build. The cache is filled only by those screens,
  so an id that was never listed — a link opened from cold, or a restart on
  the details route — falls through to the screen's unavailable state rather
  than fetching. Making those links work would mean adding a
  `fetchMovieDetails(id)` call against TMDB's `/movie/{id}`.
- **Task cancellation** — Dart futures cannot be cancelled, so a superseded load
  is handed a token and drops its result.
- **Images** — [`cached_network_image`](https://pub.dev/packages/cached_network_image).
- **Localization** — per-package `.arb` files with their own generated delegates
  (`MoviesLocalizations`, `SearchLocalizations`). After editing an `.arb`,
  re-run `flutter gen-l10n` in that package.

## Tests

```bash
./scripts/test_all.sh          # analyze + every module + the app
./scripts/test_all.sh --update-goldens
```

What is covered:

- **Unit** — error mapping, HTTP status handling, JSON parsing and URL building
  are covered in `movies_api` and `network_service` against canned payloads.
  The cubits (paging, de-duplication, retry, debounce, cancellation,
  navigation) are covered against a stubbed `MovieServicing`, using
  [`bloc_test`](https://pub.dev/packages/bloc_test) to assert the sequence of
  emitted states.
- **Widget** — every state of every screen, plus accessibility labels and the
  German translations. The views are driven by a `MockCubit` whose emissions
  the test controls; `packages/*/test/fixtures.dart` holds the canned states.
- **Golden** — the same states rendered at iPhone size and compared to the
  images in `packages/*/test/goldens/`. Text renders as blocks: Flutter's
  golden tests use a metrics-only test font.
- **App** — `test/app_test.dart` drives the composed app over a stubbed
  service: launch, tap through to details, back, and search.
- **Integration** — `integration_test/app_test.dart` drives the app against the
  real TMDB API. It needs a device and a real key:

  ```bash
  flutter test integration_test --dart-define=TMDB_API_KEY=$TMDB_API_KEY
  ```
