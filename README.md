# 🎮 CIELO-G Learning Framework

A flexible, plug-and-play learning framework for **Godot 4** that enables rapid creation of educational mini-games with built-in progress tracking, certificate generation, and modular game systems.

## 📁 Project Structure

```
CIELO-G_Learning_Framework/
├── Global/                    # Shared resources and scripts
│   ├── Assets/               # Fonts, audio, characters, themes
│   └── Scripts/              
│       ├── Managers/         # Core game management (ModuleManager)
│       ├── SetName/          # Player name input
│       ├── ThankYou/         # Completion screens
│       └── Transitions/      # Scene transition effects
│
├── Menu/                      # Main menu and navigation
│   ├── Home/                 # Home screen with play/learn buttons
│   └── MenuBar/              # Progress bar and navigation
│
├── Module/                    # Learning module components
│   ├── Learn/                # Explanation/dialogue system
│   ├── Certificate/          # Certificate generation
│   └── Play/                 # 👉 YOUR MINIGAMES GO HERE!
│       ├── Minigame_1/       # First minigame folder
│       │   ├── Assets/       # Minigame-specific visuals
│       │   └── minigame_1.tscn  # Inherited scene from system
│       ├── Minigame_2/       # Second minigame folder
│       │   ├── Assets/       # Minigame-specific visuals
│       │   └── minigame_2.tscn  # Inherited scene from system
│       └── ...               # Add more minigames
│
├── S_Clickable/              # 🎯 Clickable game system (BASE)
│   ├── ClickableSystem.tscn  # Inherit from this
│   └── Prefabs/              # Clickable prefab objects
│
├── S_DragAndDrop/            # 🎯 Drag-and-drop game system (BASE)
│   ├── DragAndDropSystem.tscn  # Inherit from this
│   └── Prefabs/              # Draggable & Source prefabs
│
└── S_MixAndMatch/            # 🎯 Mix-and-match game system (BASE)
    ├── MixAndMatchSystem.tscn  # Inherit from this
    └── Prefabs/              # Match prefab objects
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for bugs and feature requests.
