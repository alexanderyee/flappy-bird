# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

A Flappy Bird clone built with **Godot 4 / GDScript**. Portrait viewport (700x1066), Forward+ renderer, D3D12 driver on Windows.

Note a version mismatch: `project.godot` declares `config/features=("4.7", ...)`, but the `godot` CLI on this machine is **4.6.3**. Opening/saving from the CLI may rewrite the project to the older version. Prefer matching the editor version the project was authored with (4.7) when available.

## Commands

`godot` is on PATH (via scoop). All commands assume the repo root as working directory.

- Run the game: `godot --path .` (launches the main scene, `scenes/game.tscn`)
- Open the editor: `godot -e --path .`
- Run a specific scene: `godot --path . res://scenes/game.tscn`
- Headless import/reimport of assets (regenerates `.godot/`): `godot --headless --import --path .`

There is **no test framework, linter, or build/export config** in this repo. `.godot/` is a regenerable import cache (gitignored) — do not edit it.

## Architecture

The whole game lives in one scene tree rooted at `scenes/game.tscn` (`Game` node). Three gameplay scripts drive it; understanding how they connect matters more than any single file.

- **`SignalBus` (autoload, `signal_bus.gd`)** — global singleton registered in `project.godot` under `[autoload]`. Intended as the decoupled event hub. Currently declares only `signal player_collided(body)`, which is **not yet emitted or connected anywhere**. Wiring player death through this bus is the apparent intended design (see stub below).

- **`Player` (`scenes/character_body_2d.gd`, `class_name Player`)** — the `da bird` node. Gravity + a flap impulse on the `ui_accept` input action (default Space/Enter; no custom input map is defined). After `move_and_slide()` it scans slide collisions and, on hitting a `PipeSet`, currently just `print("game over")` — a stub that should route through `SignalBus.player_collided`.

- **`pipe_spawner.gd`** (`PipeSpawner` node) — on a `Timer`, instantiates `PipeSet` scenes and calls `setup(speed, random_offset, gap_size)` on each. Key structural quirk: spawned pipes are added to the **sibling `Pipes` node**, not to the spawner itself (`@onready var pipes = $"../Pipes"`). A `DespawnBarrier` (`Area2D`) off the left edge frees pipes via `_on_despawn_barrier_body_entered`. Both `Pipes` and `PipeSpawner` sit at x=1000 so pipes enter from off-screen right.

- **`PipeSet` (`scenes/pipespawner/pipe_set.gd` + `pipe_set.tscn`, `class_name PipeSet`)** — a top/bottom pipe pair. `setup()` stores speed/gap and applies a vertical offset; `_ready()` splits the pipes apart by `gap_size`; `_process()` slides the whole set left each frame.

### Conventions specific to this project

- **Preloads use UID references, not paths**: e.g. `preload("uid://bghq45rw1727i")` in `pipe_spawner.gd`. UIDs are defined in the `.uid` sidecar files and at the top of each `.tscn`. Moving a script/scene keeps its UID stable; changing a UID breaks these references.
- **Collision layers** (`[layer_names]` in `project.godot`): layer 1 = `player`, layer 2 = `pipes`. Pipes' `StaticBody2D` nodes are on layer 2; the `DespawnBarrier` masks layer 2; the player's `collision_mask` covers both.
- Pipe identification relies on `body.get_parent() is PipeSet` — collision bodies are the `TopPipe`/`BottomPipe` children, so code checks their parent, not the collider itself.
