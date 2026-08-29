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
flag, so **Run** in VS Code needs nothing extra; in Android Studio put
`--dart-define-from-file=.env.local` under *Additional run args*.

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

## Architecture

A [pub workspace](https://dart.dev/tools/pub/workspaces) of Dart packages, so a
module can only reach what it declares in its `pubspec.yaml`.

| Package | Responsibility |
|---|---|
| `packages/network_service` | `NetworkClient` seam over `package:http`, plus the domain-level `NetworkError`s. |
| `packages/movies_api` | TMDB DTOs, JSON parsing, `MovieService`. |
| `packages/movies_core` | `MovieDetails`, `MovieNavigator`, poster and rating helpers. |
| `packages/movies` | The popular-movies grid and the details screen. |
| `packages/search` | The search overlay. |
| `packages/main_navigation` | Owns the navigation stack and composes every module. |
| `packages/movies_api_mocks` | A `MovieServicing` mock and the `MovieResponse` values it returns. |
| `packages/movies_core_mocks` | Placeholder domain values. |
| `lib/main.dart` | Theme, localization delegates, entry point. |

The feature modules never import one another. `movies` and `search` depend on
the `MovieNavigator` interface in `movies_core`; `main_navigation` is the only
package that knows every module exists.

The two `…_mocks` packages are `dev_dependencies` only, so nothing in them
reaches a shipped binary. Neither is reachable from the packages it mocks, so
there is no dependency cycle. `movies_api`'s own JSON fixtures and fake client
are local to `packages/movies_api/test/fixtures.dart`, since nothing outside
that package needs them.

- **State management** — each feature owns a
  [`Cubit`](https://pub.dev/packages/flutter_bloc) publishing one immutable
  state value, which the views render through `BlocBuilder`. The state classes
  implement `==`, so re-emitting an unchanged state is not a rebuild.
- **Dependency injection** — [`get_it`](https://pub.dev/packages/get_it). Each
  module exposes a `register…()` that skips anything already registered, so
  tests and the golden harness substitute a mock simply by registering first.
- **Navigation** — a declarative `Navigator` whose `pages` are derived from
  `MainViewModel.path`. Features push through the `MovieNavigator` abstraction
  and stay unaware of each other.
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
