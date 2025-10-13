# Module/Play - Minigames Directory

This is where you create your minigames by inheriting from the base game systems.

## Structure

Each minigame should be in its own folder with this structure:

```
Minigame_1/
├── Assets/           # Minigame-specific images, sounds, etc.
└── minigame_1.tscn   # Inherited scene from one of the base systems
```

## How to Create a Minigame

1. **Choose a base system to inherit from:**
   - `S_Clickable/ClickableSystem.tscn` - For selection-based games
   - `S_DragAndDrop/DragAndDropSystem.tscn` - For drag-and-drop puzzles
   - `S_MixAndMatch/MixAndMatchSystem.tscn` - For connection games

2. **Create your minigame folder** (e.g., `Minigame_1/`)

3. **Create an inherited scene:**
   - Right-click the base system scene
   - Select "New Inherited Scene"
   - Save it in your minigame folder

4. **Add your Assets folder** for visuals specific to this minigame

5. **Register your minigame** in `Global/Scripts/Managers/ModuleManager.gd`

See the main README for detailed instructions!
