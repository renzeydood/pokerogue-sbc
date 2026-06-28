# PokeRogue Godot Port - Sample Scene (Godot 3.5)

This is a minimal test scene for validating the Godot port architecture targeting Godot 3.5.

## Setup

1. **Godot 3.5** required (download from https://godotengine.org/download)

2. **Copy minimal assets** into the Godot project so they are available under `res://`:
   ```bash
   # From repository root, copy the exported assets into the godot-port project
   cp -r godot-minimal-assets godot-port/
   ```

3. **Open the project** in Godot:
   - Launch Godot 3.5
   - Open the `godot-port/` directory as a project
   - Press Play (the project is configured to open `scenes/Main.tscn`)

## Controls

- `SPACE`: Play/stop title BGM audio
- `S`: Play select sound effect (added as `ui_select` action at runtime)

## What This Tests

- Asset loading from exported minimal set
- Sprite display
- Audio playback
- Input handling
- UI layout via script

## Asset Paths

The scene expects assets under the project at:
```
res://godot-minimal-assets/assets/images/pokemon/1.png
res://godot-minimal-assets/assets/audio/bgm/title.mp3
res://godot-minimal-assets/assets/audio/ui/select.wav
```

If assets are not found, the scene displays warnings in the Status label.

## Next Steps

1. Verify sprite and audio load correctly
2. Add more Pokémon sprites
3. Implement a simple battle turn sequence
4. Test data loading from exported game logic
