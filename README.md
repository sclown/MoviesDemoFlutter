# MoviesDemoFlutter

A Flutter port of the SwiftUI **MoviesDemo** app. It browses and searches movies
using [The Movie Database (TMDB)](https://www.themoviedb.org) API.

## Features (matching the iOS app)

- **Popular Movies** — a two-column poster grid with infinite-scroll pagination
  that de-duplicates overlapping TMDB pages.
- **Search** — a bottom search bar that dims the screen and shows live results,
  with a 500 ms debounce and stale-response cancellation.
- **Details** — poster, star rating, release date and overview.
- English and German, localized per feature module.
- Forced dark theme, matching the original's `.preferredColorScheme(.dark)`.

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
> out of it — the same is true of the original's Xcode-scheme variable. It keeps
> the key out of version control, not out of the shipped app.

## Architecture

The original is a workspace of Swift packages; this is a
[pub workspace](https://dart.dev/tools/pub/workspaces) of Dart packages with the
same boundaries, so a module can only reach what it declares.

| Package | Mirrors | Responsibility |
|---|---|---|
| `packages/network_service` | `NetworkService` | `NetworkClient` seam over `package:http`, plus the domain-level `NetworkError`s. |
| `packages/movies_api` | `MoviesApi` | TMDB DTOs, JSON parsing, `MovieService`. |
| `packages/movies_core` | `MoviesCore` | `MovieDetails`, `MovieNavigator`, poster/rating helpers, `ObservableState`. |
| `packages/movies` | `Movies` | The popular-movies grid and the details screen. |
| `packages/search` | `Search` | The search overlay. |
| `packages/main_navigation` | `MainNavigation` | Owns the navigation stack and composes every module. |
| `lib/main.dart` | `MoviesDemoApp.swift` | Theme, localization delegates, entry point. |

A few deliberate translations:

- **Dependency injection** — `Factory` becomes [`get_it`](https://pub.dev/packages/get_it).
  Each module exposes a `register…()` that skips anything already registered, so
  tests and the golden harness substitute a stub simply by registering first.
- **Observable state** — `@Observable` becomes `ObservableState`, a
  `ChangeNotifier` carrying one immutable state value plus a `didChange` hook the
  tests observe.
- **Navigation** — `NavigationStack(path:)` becomes a declarative `Navigator`
  whose `pages` are derived from `MainViewModel.path`. Features push through the
  `MovieNavigator` abstraction and stay unaware of each other.
- **Task cancellation** — Dart futures cannot be cancelled, so a superseded load
  is handed a token and drops its result, standing in for `Task.isCancelled`.
- **Images** — `NukeUI` becomes
  [`cached_network_image`](https://pub.dev/packages/cached_network_image).
- **Localization** — the per-module `Localizable.xcstrings` become per-package
  `.arb` files with their own generated delegates (`MoviesLocalizations`,
  `SearchLocalizations`). After editing an `.arb`, re-run `flutter gen-l10n` in
  that package.

## Tests

```bash
./scripts/test_all.sh          # analyze + every module + the app
./scripts/test_all.sh --update-goldens
```

What is covered:

- **Unit** — error mapping, HTTP status handling, JSON parsing, URL building,
  poster/rating helpers, both view models (paging, de-duplication, debounce,
  cancellation, navigation) and the navigation path.
- **Widget** — every state each SwiftUI preview staged, plus accessibility
  labels and the German translations.
- **Golden** — the same states rendered at iPhone size and compared to the
  images in `packages/*/test/goldens/`, the counterpart of the original's
  snapshot-over-previews suite. Text renders as blocks: Flutter's golden tests
  use a metrics-only test font.
- **App** — `test/app_test.dart` drives the composed app over a stubbed network:
  launch, tap through to details, back, and search.
- **Integration** — `integration_test/app_test.dart` is the port of
  `MoviesDemoUITests`. It needs a device and a real key:

  ```bash
  flutter test integration_test --dart-define=TMDB_API_KEY=$TMDB_API_KEY
  ```
