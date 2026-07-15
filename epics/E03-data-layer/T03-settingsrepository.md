# E03-T03 — SettingsRepository

| | |
|---|---|
| **Epic** | E03 — Data layer |
| **Status** | Not started |
| **Size** | S |
| **Depends on** | E03-T01 |
| **Blocks** | E08-T01 |

**Skills:** `reed-drift-schema` · `reed-riverpod-usage`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

Seven preferences decide whether the app is usable for a given person: which voice speaks, how fast, whether output goes to the speaker or the poster, light or dark, whether a tap buzzes, and whether the grid is 3×4 or 2×3. All seven are set once, in calm, and must still be true at 2am mid-shutdown. Two of them — `theme` and `grid_size` — must be correct on the **first painted frame**: a white flash into a dark room, or a grid that reflows from 3×4 to 2×3 a frame after launch, is a startup that hands the user the wrong tile under their thumb. There is no telemetry: if a preference silently fails to persist, nobody will ever hear about it.

## Scope

### The table

`settings` is **plain key/value** — one row per key, values stored as `String`. Seven keys, and only seven:

`voice_id` · `pitch` · `rate` · `output_mode` · `theme` · `haptics` · `grid_size`

```dart
// lib/data/tables/settings.dart
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
```

No surrogate `id`. No per-preference columns — a column per preference makes every new preference a migration against live data, and **a botched migration destroys a hand-curated board**. K/V keeps preference growth out of the migration path entirely.

### The repository

`lib/data/settings_repository.dart`. It owns the **entire** string↔typed boundary. Nothing outside this file ever sees the raw `String` values or the key names.

```dart
class SettingsRepository {
  SettingsRepository(this._db);
  final AppDatabase _db;

  Future<ReedSettings> load();                 // one query, all seven keys
  Future<void> setTheme(ThemePref v);
  Future<void> setGridSize(GridSize v);
  Future<void> setVoiceId(String? v);
  Future<void> setPitch(double v);
  Future<void> setRate(double v);
  Future<void> setOutputMode(OutputMode v);
  Future<void> setHaptics(bool v);
  Stream<ReedSettings> watch();                // drift .watch() over the table
}
```

`ReedSettings` is a plain immutable class with a `const ReedSettings.defaults()`. Writes go through `insertOnConflictUpdate` (upsert on the `key` PK) — never read-then-write, never `insert` and hope the row is absent.

Enums are persisted by **name**, not index: `theme` stores `'dark'`, not `'2'`. An index is a hidden ordering dependency — reorder the enum and every existing install silently changes theme. Serialize with `v.name`; parse with a name lookup that falls back to the default.

- `ThemePref { system, light, dark }`
- `GridSize` — the two shipping layouts: 3×4 phone default, 2×3 crisis/large (~180dp tiles). Store the name.
- `OutputMode` — the member set is owned by the speech / show-screen work; this task persists `enum.name` and parses by name. Do not invent a third mode here.
- `pitch` / `rate` — parsed with `double.tryParse`, then **clamped to the range `SpeechService` declares**. Do not invent a range in this file; import the constants.
- `voice_id` — nullable `String`; absent row ⇒ null ⇒ platform default voice.
- `haptics` — stored as `'true'` / `'false'`, parsed with an explicit `== 'true'` comparison.

### Parsing is total: no key is allowed to throw

Every getter returns a value for every possible stored string. Missing row, empty string, `'ｄａｒｋ'`, a `rate` of `'NaN'` — each resolves to the documented default. Riverpod's retry is disabled (`retry: (_, __) => null`), so a throw out of a provider body is an immediate red screen on a device that will never report it. A garbage `pitch` must never be the reason a tile is silent.

Being total is **not** being quiet: a parse that falls back logs the key and the offending value to the on-device crash/diagnostic log — the only field feedback that will ever exist — and the app keeps working.

### Restored before first paint

Settings are loaded in `main()`, before `runApp`, alongside the `AppDatabase` construction, and injected as a value. `ThemePref` and `GridSize` reach the first frame **synchronously**.

```dart
// lib/main.dart
WidgetsFlutterBinding.ensureInitialized();
final db = await AppDatabase.open();               // support dir, PRAGMA foreign_keys = ON
final settingsRepo = SettingsRepository(db);
final initial = await settingsRepo.load();         // BEFORE runApp
final speech = await SpeechService.create();

runApp(
  ProviderScope(
    retry: (retryCount, error) => null,
    overrides: [
      databaseProvider.overrideWithValue(db),
      speechServiceProvider.overrideWithValue(speech),
      settingsProvider.overrideWithValue(initial), // no loading frame, no flash
    ],
    child: const AacApp(),
  ),
);
```

### The providers

Two lines added to `lib/providers.dart`, hand-written, no codegen, no family, no `StateProvider`:

```dart
final settingsRepositoryProvider =
    Provider<SettingsRepository>((ref) => SettingsRepository(ref.watch(databaseProvider)));

// Overridden in main() with the value loaded before runApp; kept live by the
// repository's watch() so a settings-screen write repaints the app.
final settingsProvider = Provider<ReedSettings>(
  (ref) => throw UnimplementedError('settingsProvider must be overridden'),
);
```

Follow the existing seam pattern: throwing by default means an un-overridden read fails loudly at first read instead of silently constructing defaults. `isAutoDispose` stays at its hand-written default of `false` — settings are process-lifetime.

Keeping the value fresh after a settings write is a `Notifier<ReedSettings>` seeded from the injected initial value and driven by `watch()`, or a `ref.listen` off the repository stream — **not** a re-read on every build, and **not** a `StateProvider`.

### Explicitly out of scope

- The settings **screen** and any of its widgets (E08-T01).
- Mapping `ThemePref` to actual colours, and `GridSize` to actual dp — those live in the theming and grid work. This task persists and restores; it does not render.
- `boards.grid_rows` / `boards.grid_cols`. The `grid_size` setting is the user's **preference**; per-board dimensions remain real columns on `boards` and are the source of truth for layout bounds. Do not delete or shadow them.
- Enumerating voices, or validating that a stored `voice_id` still exists on the device. The speech layer owns that.
- Migrations. At `schemaVersion = 1` there are none — but the schema JSON dump at commit #1 must include `settings`.

## Acceptance criteria

- [ ] `flutter analyze` is clean.
- [ ] `grep -rn "SettingsService" lib/` returns nothing. `SettingsRepository` is the only settings type; there is no service wrapper over it.
- [ ] `grep -rn "'theme'\|'grid_size'\|'voice_id'\|'output_mode'\|'haptics'" lib/ --include='*.dart'` matches only `lib/data/settings_repository.dart`. Key strings do not leak.
- [ ] `grep -rn "StateProvider\|\.family\|@riverpod" lib/providers.dart` returns nothing.
- [ ] Test: a fresh DB with **zero** `settings` rows ⇒ `load()` returns `ReedSettings.defaults()` and throws nothing.
- [ ] Test: `setPitch` then `setPitch` again on the same key leaves exactly **one** row for `pitch` (upsert, not duplicate/throw).
- [ ] Test (table-driven, one case per key): a garbage stored value — `''`, `'dark '`, `'NaN'`, `'99999'`, `'2'` — returns the documented default and does not throw.
- [ ] Test: `pitch = '99999'` returns the clamped maximum from `SpeechService`'s declared range, not `99999`.
- [ ] Test: `setTheme(ThemePref.dark)` stores the literal string `'dark'` — assert on the raw column value, not on the round trip. Round-tripping an index would pass a round-trip test and still break every install on the next enum reorder.
- [ ] Test: round trip for all seven keys — write, construct a **new** `SettingsRepository` over the same DB, `load()`, values match.
- [ ] Test: `watch()` emits a new `ReedSettings` after `setHaptics(false)`.
- [ ] All repository tests run against `NativeDatabase.memory()` — real SQLite. No Map-backed fake.
- [ ] No test asserts that `ref.watch` propagates. Testing the framework is not testing this.
- [ ] `main()` awaits `load()` before `runApp` — verifiable by reading `lib/main.dart`: there is no `await` between `ProviderScope` and the first frame, and no `AsyncValue` in the theme path.

## Traps

- **Loading settings inside a provider body.** `FutureProvider<ReedSettings>` gives the app a loading frame, and that frame paints the default theme. A white flash into a dark room at 2am, every launch. It also puts a throwing async body behind `retry: null` — instant red screen. Load in `main()`, inject the value.
- **`MediaQuery` flags sneaking into `ReedSettings`.** If a field named `boldText`, `textScaler`, `highContrast`, or `accessibleNavigation` is about to be added — stop. Those are read at build time via `MediaQuery.boldTextOf(context)` / `highContrastOf(context)` / `textScalerOf(context)`. App state via Riverpod; platform/a11y state via `BuildContext`. At 200%+ text scale a one-frame-stale copy is total failure, not a cosmetic bug.
- **Persisting an enum by index.** `theme` = `'2'` survives every test you will write and breaks silently the day someone alphabetizes the enum. Store `.name`.
- **`double.parse` instead of `double.tryParse`.** One corrupt `rate` row and the app throws in `main()` before it can paint — bricked, with no way for the user to reach the settings screen to fix it. `tryParse` + default + log.
- **Read-modify-write instead of upsert.** `select` → check → `insert`-or-`update` is three statements and a race. `insertOnConflictUpdate` is one.
- **A per-preference column table.** It looks tidier and it costs a `TableMigration` per preference, forever, against live user data. K/V exists precisely so preference #8 is an insert, not a migration.
- **Growing `lib/providers.dart`.** Two providers is the budget here. Provider count going up is a smell, not progress. The moment `family` is typed to key settings by anything, the argument that Riverpod was cheap is lost.
- **Treating `grid_size` as the layout's source of truth.** Bounds come from `boards.grid_rows` / `boards.grid_cols` and are enforced in `BoardRepository`, not from this preference and never in SQL. Never write `const kRows = 4`, and never add a `CHECK` constraint on `grid_slots` — a CHECK makes the 2×3 layout a database-level insert failure.
- **Swallowing a failed write.** `setHaptics` that catches and drops a `SqliteException` means a preference that appears to save and reverts on next launch, with no error path anyone will ever see. Let it throw; the caller decides.
- **A widget importing `package:drift` to read a setting.** No widget imports drift. `ReedSettings` is a plain class specifically so the settings screen never touches a row class or a Companion.

## Files

- `lib/data/tables/settings.dart` — new. The `Settings` drift table.
- `lib/data/database.dart` — changed. Register `Settings` in `@DriftDatabase(tables: [...])`.
- `lib/data/settings_repository.dart` — new. `SettingsRepository`, `ReedSettings`, `ThemePref`, `GridSize`, key constants, parsers.
- `lib/providers.dart` — changed. `settingsRepositoryProvider`, `settingsProvider`.
- `lib/main.dart` — changed. Load before `runApp`; add the `settingsProvider` override.
- `test/data/settings_repository_test.dart` — new.
- `drift_schemas/` + `.g.dart` — regenerated, committed.

## Done when

`flutter test test/data/settings_repository_test.dart` passes against real in-memory SQLite, and a device with `theme = dark` and `grid_size = 2x3` paints the dark 2×3 board on its first frame with no flash and no reflow.
