# Code Review — MoviesDemoFlutter

**Date:** 2026-08-28
**Scope:** whole codebase (app + all six workspace packages)
**Verification:** `flutter analyze` → *No issues found*. `./scripts/test_all.sh` → all ~89 automated
tests pass. The 5 `integration_test/` cases were **not** run (they need a device and a real TMDB key).

---

## What's genuinely good

The module boundaries are real, not decorative. `movies` and `search` don't know each other exists;
they talk to `movies_core`'s `MovieNavigator` interface, and `main_navigation/lib/src/module.dart` is
the single place that knows the whole graph. That's the hard part of modular architecture and it's
done correctly.

Other things worth keeping:

- The `register…()` idempotence pattern (`if (isRegistered) return`) as a test seam is elegant.
- The pub-workspace setup with `resolution: workspace` is the current-correct approach.
- `strict-casts` / `strict-raw-types` plus `prefer_relative_imports` is a stronger lint set than most
  projects run.
- `movies_api` and `network_service` are pure Dart with `test:` rather than `flutter_test:`, so they
  run without the Flutter harness.
- Test coverage is unusually thorough for a demo — unit, widget, golden, app-level.

The code reads as deliberate. Comments explain *why* (the `addPostFrameCallback` note, the
keyed-slots note in `SearchOverlay`), which is rare.

---

## Real bugs

### 1. Search failures are reported to the user as "no results"

`packages/search/lib/src/search_view_model.dart:99` catches every error, clears `_searchResults`, and
line 108 then computes `showEmptyLabel: _searchResults.isEmpty && query.isNotEmpty` → true. A dropped
connection tells the user "No results for 'Batman'". `SearchState` has no error field at all.

This is the most user-visible defect.

### 2. `NetworkError.timeout()` can never fire in production

`packages/network_service/lib/src/network_client.dart:34` calls `_client.get(url)` with no timeout,
and nothing else throws `TimeoutException`. The mapping at
`packages/network_service/lib/src/network_error.dart:25` is only reachable from tests. A hung request
hangs until the OS gives up.

Fix: add `.timeout(const Duration(seconds: 30))`.

### 3. `onDidRemovePage` pops blindly

`packages/main_navigation/lib/src/main_navigation_view.dart:42` does
`path.sublist(0, path.length - 1)` regardless of *which* page was removed. If two removals land before
a rebuild, the second call hits `sublist(0, -1)` → `RangeError`.

Fix by filtering on the removed page's key:

```dart
onDidRemovePage: (page) => _viewModel.reset(
  _viewModel.path.where((m) => page.key != ValueKey('details-${m.id}')).toList(),
),
```

The same `ValueKey('details-${movie.id}')` also collides if the same movie ever appears twice on the
stack.

### 4. TMDB is always asked for English

`packages/movies_api/lib/src/movie_service.dart:79` hardcodes `'language': 'en-US'` while the app
ships German UI strings. In German the chrome is translated and every title/overview is not. The
service should take the locale.

### 5. The integration tests almost certainly fail as a suite

`integration_test/app_test.dart:34` is `setUp(registerModules)` with no `tearDown(GetIt.instance.reset)`
— unlike `test/app_test.dart:26`, which does reset. `MainViewModel` is a singleton, so the movie
pushed in *"tapping a movie opens its details"* is still on the path when the next test starts; the
grid and search field are then offstage and `find.byType(...)` skips offstage by default.

Not confirmed by a run (needs a device and a key) — treat as "very likely broken".

### 6. `isLoadingMore` is tracked but never rendered

Set in `packages/movies/lib/src/list/movies_view_model.dart:107` and `:129`, asserted in tests, read
by no widget. Either show a footer spinner in `MoviesView._movieGrid` or delete the field.

---

## Design issues

### `movies_core` depends on `movies_api`

The domain layer depends on the DTO layer, and `MovieTools` is an extension on the wire type `Movie`.
It works, but the dependency arrow points the wrong way — the usual shape is `movies_api` mapping DTOs
*into* core models, with core depending on nothing. It's why every feature package must import
`movies_api` too.

### Test fixtures ship in production `lib/`

`MovieDetails.mock()`, `MovieCard.mockWith`, `MoviesListState.mockMovies`, `SearchState.searching()`,
plus whole files `network_service/lib/mocks.dart` and `movies_api/lib/mocks.dart`. Tree-shaking mostly
removes them, but they're part of each package's public API — anything can call `MovieDetails.mock()`
in shipping code. The idiomatic fix is a separate `_testing` package, or at minimum consolidating them
out of the domain types.

### The theme is copy-pasted three times

`lib/main.dart:40` says *"Shared by the app and the golden tests, so what is asserted is what ships"* —
but `packages/movies/test/preview.dart` and `packages/search/test/preview.dart` each define their own
`previewApp` with a hand-copied `ThemeData`, and the search one has already drifted (no `appBarTheme`).
The comment describes an intent the code doesn't implement, and **the goldens are asserting a theme
that isn't the shipped one**.

A feature package can't import the app, so the theme belongs in `movies_core` (or a `design_system`
package) with `main.dart` and both previews importing it.

### Service locator reached from widget state

`packages/movies/lib/src/list/movies_view.dart:28`,
`packages/search/lib/src/search_overlay.dart:25`,
`packages/main_navigation/lib/src/main_navigation_view.dart:22` all call `GetIt.instance<T>()`
directly. Testable via pre-registration, but it's a global, so tests are order-dependent and every
widget is coupled to the container. Passing the view model in as a constructor argument (with the
module still doing the wiring) removes the coupling without changing the architecture.

### `ObservableState.value` notifies unconditionally

`packages/movies_core/lib/src/observable_state.dart:23`, and no state class implements `==`. Every
`_updateState` rebuilds the whole grid. Fine at this size; worth knowing.

---

## Smaller things

- `dart:io` in `movie_service.dart:5` and `network_error.dart:6` rules out Flutter web. Fine if
  iOS/Android is the target, but it's an unstated constraint.
- No pull-to-refresh, and load-more errors are swallowed silently
  (`movies_view_model.dart:123`) with no way to retry that page.
- The `_Cancellation` class is duplicated verbatim in both view models — it belongs in `movies_core`.
- The `addPostFrameCallback` at `movies_view.dart:85` registers a new callback on every rebuild of the
  last cell; `loadMoreIfNeeded` is guarded so it's harmless, but a scroll-position listener is the more
  conventional trigger.
- `intl: any` in both feature pubspecs — Flutter pins it anyway, but it's a loose constraint.
- `supportedLocales: MoviesLocalizations.supportedLocales` in `main.dart` silently assumes both feature
  modules support the same locales.
- 34 packages are behind (`flutter_lints` 5→6, `get_it` 8→9).
- No CI config. Given `scripts/test_all.sh` already exists, a GitHub Actions workflow calling it is
  about ten lines.

---

## Overall

This is well above the quality bar for a port/demo — the boundaries hold, the tests are real, and the
intent is documented.

Suggested order of work:

1. Search-error-as-empty-results (bug #1)
2. The `en-US` hardcode (bug #4)
3. The triplicated theme — it quietly undermines what the golden tests are supposed to prove
