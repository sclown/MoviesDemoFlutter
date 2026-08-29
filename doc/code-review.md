# Code Review — MoviesDemoFlutter

**Reviewed:** 2026-08-28 · **Updated:** 2026-08-29
**Scope:** whole codebase (app + all eight workspace packages)
**Verification:** `flutter analyze` → *No issues found*. `./scripts/test_all.sh` → all 89
automated tests pass. The 5 `integration_test/` cases were **not** run (they need a device and a
real TMDB key).

---

## What's genuinely good

The module boundaries are real, not decorative. `movies` and `search` don't know each other exists;
they talk to `movies_core`'s `MovieNavigator` interface, and `main_navigation/lib/src/module.dart` is
the single place that knows the whole graph. That's the hard part of modular architecture and it's
done correctly.

Other things worth keeping:

- The `register…()` idempotence pattern (`if (isRegistered) return`) as a test seam.
- The pub-workspace setup with `resolution: workspace` — the current-correct approach.
- `strict-casts` / `strict-raw-types` plus `prefer_relative_imports`: a stronger lint set than most
  projects run.
- `movies_api` and `network_service` are pure Dart, so they run without the Flutter test harness.
- Test coverage is unusually thorough — unit, widget, golden, app-level.

---

## Open — bugs

### 1. Search failures are reported to the user as "no results"

`packages/search/lib/src/search_cubit.dart:93` catches every error and clears `_searchResults`; line
105 then computes `showEmptyLabel: _searchResults.isEmpty && query.isNotEmpty` → true. A dropped
connection tells the user "No results for 'Batman'". `SearchState` has no error field at all.

The most user-visible defect. A sealed `Result` type in `movies_core` would make "failed" and
"returned nothing" distinct cases the compiler forces you to handle.

### 2. `NetworkError.timeout()` can never fire in production

`packages/network_service/lib/src/network_client.dart:34` calls `_client.get(url)` with no timeout,
and nothing else throws `TimeoutException`. The mapping in `network_error.dart` is only reachable
from tests. A hung request hangs until the OS gives up.

Fix: `.timeout(const Duration(seconds: 30))`.

### 3. `onDidRemovePage` pops blindly

`packages/main_navigation/lib/src/main_navigation_view.dart:42` does
`path.sublist(0, path.length - 1)` regardless of *which* page was removed. Two removals before a
rebuild make the second call `sublist(0, -1)` → `RangeError`.

```dart
onDidRemovePage: (page) => _viewModel.reset(
  _viewModel.path.where((m) => page.key != ValueKey('details-${m.id}')).toList(),
),
```

The same `ValueKey('details-${movie.id}')` also collides if one movie appears twice on the stack.

### 4. TMDB is always asked for English

`packages/movies_api/lib/src/movie_service.dart:78` hardcodes `'language': 'en-US'` while the app
ships German UI strings. In German the chrome is translated and every title and overview is not.

### 5. The integration tests almost certainly fail as a suite

`integration_test/app_test.dart:32` is `setUp(registerModules)` with no `tearDown(GetIt.instance.reset)`
— unlike `test/app_test.dart`, which does reset. `MainViewModel` is a singleton, so the movie pushed
in *"tapping a movie opens its details"* is still on the path when the next test starts; the grid and
search field are then offstage, and `find.byType(...)` skips offstage by default.

Not confirmed by a run (needs a device and a key) — treat as "very likely broken".

### 6. `isLoadingMore` is tracked but never rendered

Emitted by `MoviesCubit`, asserted in the cubit tests, read by no widget. Either show a footer
spinner in `MoviesView._movieGrid` or drop the field.

---

## Open — design

### `movies_core` depends on `movies_api`

`packages/movies_core/pubspec.yaml:15`. The domain layer depends on the DTO layer, and `MovieTools`
is an extension on the wire type `Movie`. The usual shape is `movies_api` mapping DTOs *into* core
models, with core depending on nothing.

### The theme is copy-pasted three times

`lib/main.dart:43` plus `packages/{movies,search}/test/test_harness.dart`, and the search copy has
already drifted (no `appBarTheme`). **The goldens are therefore asserting a theme that isn't the
shipped one.** A feature package can't import the app, so the theme belongs in `movies_core` (or a
`design_system` package) with `main.dart` and both harnesses importing it.

### Service locator reached from widget state

`movies_view.dart:29`, `search_overlay.dart:25`, `main_navigation_view.dart:22` all call
`GetIt.instance<T>()` directly. Testable via pre-registration, but every widget is coupled to a
global and tests become order-dependent. Passing the cubit in as a constructor argument (with the
module still doing the wiring) removes the coupling without changing the architecture.

---

## Open — smaller

- `dart:io` in `movie_service.dart` and `network_error.dart` rules out Flutter web. Fine if
  iOS/Android is the target, but it's an unstated constraint.
- No pull-to-refresh, and load-more errors are swallowed silently with no way to retry that page.
- `_Cancellation` is duplicated verbatim in `movies_cubit.dart` and `search_cubit.dart` — it belongs
  in `movies_core`.
- The `addPostFrameCallback` in `movies_view.dart` registers a new callback on every rebuild of the
  last cell. Guarded, so harmless, but a scroll-position listener is the conventional trigger.
- `intl: any` in both feature pubspecs.
- `supportedLocales: MoviesLocalizations.supportedLocales` in `main.dart` assumes both feature
  modules support the same locales.
- 45 packages are behind (`flutter_lints` 5→6, `get_it` 8→9).
- No CI config. `scripts/test_all.sh` already exists, so a GitHub Actions workflow calling it is
  about ten lines.

---

## Resolved since the first review

- **Test fixtures no longer ship.** `MovieDetails.mock()`, `MovieCard.mockWith`,
  `MoviesListState.mockMovies`, `SearchState.searching()` and the `mocks.dart` files in
  `network_service` / `movies_api` are gone from every production `lib/`. Cross-package doubles now
  live in `packages/movies_api_mocks` and `packages/movies_core_mocks` (both `dev_dependency` only);
  module-local UI states live in `packages/{movies,search}/test/fixtures.dart`. Neither mocks package
  is reachable from the package it mocks, so there is no dependency cycle.
- **`ObservableState` is gone.** Replaced first by `ValueNotifier`, then by
  [`Cubit`](https://pub.dev/packages/flutter_bloc). `MoviesListState`, `SearchState`, `MovieCard` and
  `SearchCard` now implement `==`/`hashCode`, so an unchanged state is no longer a rebuild.
- **The bespoke test infrastructure is gone.** `StateLogger` and the two duplicate
  `TestStateLogger` classes were replaced by `bloc_test` (`blocTest`, `MockCubit`, `whenListen`).
- **The cubit suites stub the service, not the network.** `MoviesCubit` and `SearchCubit` are tested
  against a `MovieServicing` mock returning `MovieResponse` fixtures, rather than a real
  `MovieService` over canned JSON. `Json` and `MockNetworkClient` are now local to
  `packages/movies_api/test/fixtures.dart`. **Trade-off:** those suites no longer exercise URL
  building, HTTP status handling or JSON parsing — that coverage now lives solely in `movies_api`'s
  own tests, and nothing exercises the seam between the two layers end to end.
- **The retry path is now tested.** Previously, deleting `_hasLoaded = false` from `_performLoad`'s
  catch block left every test green while the Retry button went dead. `load can be retried after a
  failure` in `movies_cubit_test.dart` closes that hole.
- **`packages/*/build/` is gitignored.** The root `/build/` rule is anchored and missed roughly
  200 MB of per-package build output.

### Note for whoever changes state emission next

`BlocBase.emit` is `if (state == _state && _emitted) return;`. The `_emitted` flag means the *first*
emission always goes out even when it equals the initial state — which is why `load()` still emits
its opening `isLoading: true`. A plain `ValueNotifier` has no such escape hatch; adding `==` to the
state classes under `ValueNotifier` silently dropped that transition and hung every test that awaited
it.

---

## Overall

Well above the quality bar for a demo — the boundaries hold, the tests are real, and the intent is
documented. Suggested order of work:

1. Search-error-as-empty-results (bug #1)
2. The `en-US` hardcode (bug #4)
3. The triplicated theme — it quietly undermines what the golden tests are supposed to prove
