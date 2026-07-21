# TopFarmer Project Context

## Engine and Renderer

- Engine: Godot `4.7.1.stable.official` build `a13da4feb`, standard build, not .NET.
- Installed binary: `C:\Tools\Godot\godot.exe`; available on PATH as `godot`.
- Verify with `godot --version`; expected output is `4.7.1.stable.official.a13da4feb`.
- This engine version is pinned. Changing it requires human escalation. Export templates must match 4.7.1 exactly or exporting can fail silently.
- Renderer: Compatibility (`gl_compatibility`). Do not change it. It is the widest-compatibility mobile option and Forward+ is unnecessary for this 2D game.

## Target Platforms and Display Envelope

- v1 target: Android 10 / API 29 or newer, ARM64, at least 3 GB RAM, OpenGL ES 3.0-class graphics, and a physical display of at least 720 × 1280 in portrait.
- Future packaging target: iOS 15 or newer on A12-class hardware or better. iOS is not shipped in v1, but gameplay code must remain portable and must not call Android APIs outside `res://scripts/platform/`.
- Orientation: portrait only.
- Logical design resolution: 540 × 960. Use stretch mode `canvas_items` and aspect `expand`; anchor UI to containers and safe areas rather than fixed pixels.
- Supported portrait aspect range: height:width from 16:9 through 20:9, equivalently width/height from 0.45 through 0.5625. Wider tablets may letterbox the farm playfield while HUD and safe-area backgrounds remain valid.
- Touch is primary. Mouse input may support editor testing but cannot define interaction behavior.

## Repository Structure

Create folders only when an active task needs them.

| Path | Purpose |
|---|---|
| `res://project.godot` | Pinned Godot project configuration and autoload registration |
| `res://MD Docs/` | PM-owned routing, roadmap, decisions, tasks, and progress contracts |
| `res://data/` | PM-owned balance workbook, generated CSVs, imports, and balance tools |
| `res://autoload/` | Global singletons such as strict balance data, strings, and save state |
| `res://scenes/farm/` | Farm world, plots, terrain, and camera scenes |
| `res://scenes/buildings/` | Production-building scenes and reusable components |
| `res://scenes/ui/` | HUD, menus, popups, boards, quests, and edit-mode scenes |
| `res://scripts/data/` | CSV schemas, parsing helpers, and typed data access |
| `res://scripts/farm/` | Plot, crop, interaction, camera, and farm-state logic |
| `res://scripts/production/` | Recipe queues and production-building logic |
| `res://scripts/save/` | Versioned serialization, migration, integrity, and atomic-write helpers |
| `res://scripts/platform/` | Thin platform services such as trusted-time capability and safe areas |
| `res://scripts/ui/` | Presentation controllers; no gameplay rules or balance literals |
| `res://localization/strings.json` | Single keyed source for every user-facing v1 string |
| `res://assets/source/ai/` | Original prompts, generation metadata, and lossless AI source art |
| `res://assets/sprites/` | Reviewed runtime PNG sprites organized by terrain/crops/buildings/UI |
| `res://assets/audio/` | Reviewed royalty-free music and SFX |
| `res://assets/licenses/` | Source URLs, author, license text, and attribution records |
| `res://tests/` | Headless first-party verification scripts and fixtures; no third-party test addon without approval |

## Naming Conventions

- Scene files: lowercase snake case, such as `farm_world.tscn` and `order_board.tscn`.
- Script files: lowercase snake case matching their primary class, such as `balance.gd` and `farm_plot.gd`.
- Named GDScript classes and nodes: PascalCase, such as `FarmPlot` and `HarvestFeedback`.
- Signals, methods, variables, and groups: lowercase snake case.
- Sprite files: `<data_id>_<role>_<state>_<size>.png`, for example `sunwheat_crop_ready_256.png`; omit segments that do not apply but never use spaces.
- Data IDs: lowercase snake case. They are stable join keys between CSVs, saves, scenes, and code. Display names are never join keys.
- String keys: dotted lowercase namespaces, such as `hud.currency.gold` and `plot.action.harvest`.

## Asset Pipeline

- Store generation prompts, seeds, source files, and metadata in `res://assets/source/ai/`. Never generate directly into runtime folders.
- Commit the style guide and locked J3 recipe before bulk production. Every generation records the recipe version.
- World perspective: use a mostly overhead 2D bird's-eye view angled down slightly, similar to the camera framing of Stardew Valley but without copying its assets or style. The ground uses a screen-aligned orthogonal square grid. Sprite artwork conveys height by showing top surfaces and a small front face where useful. Do not use an isometric projection, diamond tiles, 30-degree isometric axes, or diagonal grid movement.
- Terrain master: seamless 256 × 256 square for a 128 × 128 runtime tile. Crops, props, and characters/pets: transparent 512 × 512 master exported to a 256 × 256 runtime canvas. Buildings: transparent 1024 × 1024 master exported to a 512 × 512 runtime canvas. UI icons: 256 × 256 master exported at 128 × 128 and 64 × 64.
- Use lossless PNG with straight alpha. Downsample with a high-quality Lanczos filter and visually inspect at logical resolution.
- Pivot convention: bottom center at the object's ground-contact point. The pivot remains at the same normalized location across states and flips.
- Global light: key light arrives from upper left at approximately 35° above the ground plane; cast shadows travel down and right.
- Shadows: soft painted contact/cast shadows live on a separate sprite layer beneath the object, use neutral cool gray with partial alpha, and never include hard black baked halos in the color sprite.
- Bulk assets that fail palette, perspective, light, shadow, scale, outline, or pivot checks are rejected rather than patched inconsistently.

## Balance Data Loading

- `res://autoload/balance.gd` is the `Balance` autoload and loads all seven CSVs synchronously during startup: `globals.csv`, `crops.csv`, `goods.csv`, `buildings.csv`, `progression.csv`, `orders.csv`, and `currencies.csv`.
- Read each file with `FileAccess.open("res://data/<name>.csv")`. Parse headers strictly, reject duplicate IDs/keys, reject missing required columns, and fail loudly with file and row context.
- Parsed tables live only in the `Balance` singleton: globals keyed by `Key`; crops, goods, and buildings keyed by `id`; progression keyed by integer `level`; orders keyed by `order_id`; currencies retained as validated rows grouped by `currency` and `flow`.
- Public access is read-only through explicit methods such as `get_global(key)`, `get_crop(id)`, `get_good(id)`, `get_building(id)`, `get_level(level)`, `get_order(id)`, and `get_currency_rows(currency, flow)`.
- No gameplay number may be hardcoded in code, scenes, shaders, animations, or UI. If a required value is absent, the Coder requests a balance change from the PM.

## CSV Import Setting

CSVs in `/data/` MUST be imported as **Keep File (exported as is)**. Godot's default treats `.csv` as localization data and generates `.translation` resources per column. A red X icon on these files in the FileSystem dock is CORRECT and expected, not an error; it means Godot is leaving them alone. Any NEW CSV added to `/data/` must have this setting applied manually or it will break the data pipeline. Read balance files with `FileAccess.open("res://data/<name>.csv")`.

## Save System and Clock Integrity

- Save locally to `user://savegame.json` as versioned UTF-8 JSON. The root contains `schema_version`, player/farm state, inventories, jobs, layouts, `last_trusted_utc`, and `entitlements` as a set of boolean flags initially false.
- Write atomically: serialize to `user://savegame.tmp`, flush and close, validate that it parses, then replace `savegame.json`. Keep one recoverable `savegame.backup.json` from the last valid write.
- Every crop or production timer stores integer absolute UTC Unix timestamps such as `started_at_utc` and `ready_at_utc`, never remaining duration.
- In-session elapsed time uses a monotonic clock. On resume or restart, the thin platform layer reports whether automatic/trusted device time is available. If time is untrusted, moves backward, conflicts with the monotonic observation, or exceeds the data-driven offline-integrity window, grant zero offline elapsed, preserve the jobs, and surface a keyed clock-integrity notice. Never silently award suspicious elapsed time.
- Offline limits and integrity thresholds are balance globals, not code literals. A PM balance task must add them before the save/timer implementation task.
- v1 has no cloud save, account, or network time dependency. Platform-specific checks remain behind the portable platform interface.
- Changing this format after content exists requires human escalation and a migration plan.

## Godot Commands

Two Godot binaries are on PATH:

- `godot` — GUI editor. Use for opening the editor and F5 test runs. It does not return stdout on Windows.
- `godot_console` — console wrapper. Use for every command-line, headless, import, test, and export invocation; otherwise automated checks can appear to succeed silently.

Commands are run from the repository root:

```powershell
godot --version
godot --editor --path .
godot_console --headless --editor --path . --quit
godot_console --headless --path . --quit
```

For gameplay checks, open with `godot --editor --path .` and use F5. A task that introduces a headless test must state its exact `godot_console` command in acceptance evidence.

`export_presets.cfg` is gitignored because it can contain signing credentials. Export presets are configured locally by the human, never by the Coder. Any task requiring export must name the human prerequisite and preset. The canonical v1 preset name is `Android`; after the human creates it with the matching SDK, JDK 17, template, package ID, and signing configuration, the command is:

```powershell
godot_console --headless --path . --export-debug "Android" <human-approved-output-path>\TopFarmer-debug.apk
```

## Localization Discipline

No user-facing string is hardcoded in a scene or script. All v1 text lives in `res://localization/strings.json`, keyed by dotted lowercase IDs and loaded through one string service. Scenes and scripts store keys only. Translations are out of scope for v1, but this indirection is mandatory from the first UI task. Developer diagnostics and assertion text are not user-facing strings.
