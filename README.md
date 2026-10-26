# Digimon V-Pet (Prototype)

A cross-platform Digimon virtual pet with a handheld-style Digivice game and a companion storage app.

## Tech Stack
- **Godot 4.3** (GDScript) - Cross-platform 2D engine ideal for pixel art handheld games. Exports to mobile, desktop, and web. Single codebase for game + companion UI.
- **JSON data files** - Data-driven design for Digimon, evolutions, foods, upgrades (edit data/, not code)
- **Local save files** (.save JSON) - Persistent storage for pet state, inventory, storage box, scanned digimon
- **Resource system** (Godot Resources) - Clean data structures

## Project Structure
- `scenes/` - Game scenes (Digivice UI, battle, explore, training, etc.)
- `scripts/` - Core logic (GameManager, Pet, Battle, SaveLoad, etc.)
- `data/` - JSON definitions (digimon.json, evolution.json, foods.json, digivice_upgrades.json)
- `art/` - 64x64+ pixel art sprites and UI
- `ui/` - UI themes and components
- `autoloads/` - Global singletons (GameManager, DataManager, SaveManager)

## Features
- Real-time care loop (hunger, strength/energy, mood, sleep, care mistakes)
- Friendship system affecting evolution and stats
- Training minigames for stat gains with fatigue
- Feeding with varied food effects
- Node-based adventure/exploration
- Turn-based PVP battle system (LAN/Local)
- Branching evolution tree (Baby → Rookie → Champion → Ultimate → Mega)
- Scan system for unlocking Digimon (QR/code-based)
- Companion app for storage box (view/store/retrieve/transfer)
- Digivice upgrade system gating scan tiers

## Running
Open project in Godot 4.3+. Main scene: `scenes/main/Digivice.tscn`
Companion app: `scenes/companion/CompanionApp.tscn`
