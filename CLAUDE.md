# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

A Flappy Bird clone in **Godot 4 / GDScript**, built as a "20 games challenge" learning project. Portrait viewport (700x1066), Forward+ renderer, D3D12 driver on Windows.

Version gotcha: `project.godot` declares `config/features=("4.7", ...)`, but the `godot` CLI on this machine (via scoop) is **4.6.3**. Opening/saving from this CLI can rewrite project files to the older version — prefer a 4.7 editor when available.

## Commands

`godot` is on PATH; run from the repo root.

- Run the game: `godot --path .`
- Open the editor: `godot -e --path .`
- Headless asset reimport (regenerates `.godot/`, a gitignored cache — never edit it): `godot --headless --import --path .`
- Export (presets in `export_presets.cfg`, outputs to `bin/`):
  - `godot --headless --export-release "Web" bin/flappy_bird.html`
  - `godot --headless --export-release "Windows Desktop" "bin/flappy bird.exe"`

There is no test framework or linter.

## Architecture

Everything lives in one scene tree rooted at `scenes/game.tscn`. `game.gd` (the `Game` node) is the orchestrator: it connects all `SignalBus` signals, owns the current-run `score`, and drives game-over/restart by toggling flags on the other nodes.

Event flow goes through the **`SignalBus` autoload** (`signal_bus.gd`), all three signals connected in `game.gd._ready()`:

- `player_collided` — emitted by `Player.crash()` (`scenes/character_body_2d.gd`) when a slide collision's parent is a `PipeSet` or the collider is `Floor`. Note it re-emits every physics frame while the dead bird is still touching a pipe; handlers must tolerate repeats.
- `player_cleared_pipe` — emitted by the clearance `Area2D` in `pipe_set.gd`; `game.gd` increments score and updates the UI.
- `game_restarted` — emitted by the game-over panel's restart button.

Non-obvious behaviors to preserve when editing:

- **Restart is a manual state reset, not a scene reload.** `game.gd.start()` re-arms parallax autoscroll, clears pipes, teleports the bird, and resets score. Any new mutable state must be reset there too (the bird's `velocity` currently is not — a known latent quirk masked by the restart input doubling as a jump press).
- **Game phase is implicit.** There is no state enum; "game over" is encoded in scattered flags: `Player.input_disabled`, `PipeSpawner.spawn_disabled`, and `%GameOverPanel.visible` (polled in `game.gd._process` with a 0.5s `seconds_since_game_over` delay to gate restart input).
- **The `jump` input action** (Space or left mouse button, defined in `project.godot [input]`) is polled via `Input` in both the player (flap) and `game.gd` (restart) — it is intentionally the do-everything input.
- **The spawner parents pipes to a sibling.** `pipe_spawner.gd` uses `@onready var pipes = $"../Pipes"` and adds spawned `PipeSet`s there, not under itself. Both nodes sit at x=1000 so pipes enter from off-screen right; a `DespawnBarrier` `Area2D` frees them past the left edge.
- **`PipeSet.setup()` must be called before `add_child()`**: `_ready()` applies the gap stored by `setup()`, so adding first yields a zero gap.
- **Pipe identification is structural**: collision bodies are the `TopPipe`/`BottomPipe` children, so code checks `body.get_parent() is PipeSet`, never the collider itself.
- High score persists as JSON to `user://score.save` (`score_manager.gd`); it is updated live during play and saved on game over.

## Conventions

- **Preloads use UID references** (`preload("uid://...")`), not `res://` paths. UIDs live in `.uid` sidecar files and `.tscn` headers; moving a file keeps its UID stable, but changing a UID breaks these references.
- Collision layers (`project.godot [layer_names]`): 1 = `player`, 2 = `pipes`, 3 = `despawner`. The despawn barrier masks the pipes layer.
- Scripts are typed GDScript with `class_name` declarations; keep new code typed.
