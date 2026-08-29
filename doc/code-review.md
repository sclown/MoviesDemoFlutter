# Code Review — MoviesDemoFlutter

**Reviewed:** 2026-08-28 · **Updated:** 2026-08-29
**Scope:** whole codebase (app + all seven workspace packages)
**Verification:** `flutter analyze` → *No issues found*. `./scripts/test_all.sh` → all 88 automated
tests pass across 6 suites. `flutter test integration_test` → 5/5 on an iPhone 16 Pro simulator
against the live TMDB API. `flutter build apk --debug|--release` and `build appbundle` all succeed.

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

### 1. `isLoadingMore` is tracked but never rendered

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

### `MovieCache` grows without bound

`packages/movies_core/lib/src/movie_cache.dart` keeps every movie the grid or a search ever returned,
with no eviction and no staleness check. Harmless at demo scale; a TTL or an LRU bound is the fix if
the catalogue or the session gets long.

## Open — smaller

- `dart:io` in `movie_service.dart` and `network_error.dart` rules out Flutter web. Fine if
  iOS/Android is the target, but it's an unstated constraint.
- No pull-to-refresh, and load-more errors are swallowed silently with no way to retry that page.
- `_Cancellation` is duplicated verbatim in `movies_cubit.dart` and `search_cubit.dart` — it belongs
  in `movies_core`, next to `describeError` which was de-duplicated the same way.
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
- **Search failures are reported as failures.** `SearchState` gained an `errorMessage`, `SearchCubit`
  sets it from `describeError`, and `SearchOverlay` renders a new `SearchErrorView` instead of the
  empty-results label. `showEmptyLabel` is now only set when the search actually succeeded, so a
  dropped connection no longer says "No results for 'Batman'".
- **HTTP requests time out.** `HttpNetworkClient` takes a `timeout` (30s default) and applies it, so
  `NetworkError.timeout()` is reachable from production rather than only from tests.
- **TMDB is asked for the language the UI is in.** `MovieService` takes a `String Function() language`
  read per request; the app supplies `currentLanguageTag()`, which resolves the platform locales
  against `MoviesLocalizations.supportedLocales` the same way `MaterialApp` does. A locale change
  mid-session reaches the next request.
- **`NoopNavigator` and `registerMoviesCore()` are gone.** They were unreachable — nothing outside
  their own tests called `registerMoviesCore()` — and the only path that reached the no-op was the
  one where it silently disabled every poster tap, since both registrations guard on
  `if (!isRegistered<MovieNavigator>())` and the first one wins. Both cubits already default to their
  own no-op callback, so nothing was protecting anything. `MovieNavigator` stays: it is the seam that
  keeps `search` from importing `movies`. `movies_core` now depends on no packages at all.
- **The integration suite passes.** It was leaking state between tests — `setUp(registerModules)`
  with no `tearDown(GetIt.instance.reset)`, so the cubits, the cache and the navigator survived into
  the next test and it started on whatever screen the last one left behind. Confirmed by running it
  on a simulator: 4 passed, `navigating back returns to the grid` failed. With the teardown added it
  is 5/5, and the run dropped from 79s to 33s.
- **The retry path is now tested.** Previously, deleting `_hasLoaded = false` from `_performLoad`'s
  catch block left every test green while the Retry button went dead. `load can be retried after a
  failure` in `movies_cubit_test.dart` closes that hole.
- **The details screen reads from a cache instead of a routed object.** `MovieNavigator.navigate`
  takes an id, the route is `/details/:id`, and `MovieCache` in `movies_core` is filled by the list
  and search cubits. This removed an unchecked `state.extra! as MovieDetails` cast that threw when
  the route was reached without one. **Known limit:** the cache is never populated from the network,
  so a cold-start deep link would always miss and show the unavailable state. Deep links are not
  supported at all today; making them work means adding `fetchMovieDetails(id)` first.
- **Navigation moved to the app and onto Flutter's `Navigator`.** `packages/main_navigation`,
  `MainViewModel` and the hand-rolled `Navigator(pages:)` are gone; `lib/navigation.dart` holds an
  `AppNavigator` that pushes through a `GlobalKey<NavigatorState>`. This retired the
  `onDidRemovePage` bug, which was a defect in the hand-rolled page-stack management. `go_router` was
  trialled and removed: with one push and no deep links it earned nothing, and its `/details/:id`
  builder carried an unchecked `int.parse` that threw on a malformed link.
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

1. The triplicated theme — it quietly undermines what the golden tests are supposed to prove
2. `movies_core` depending on `movies_api`
3. The `isLoadingMore` field that nothing renders
