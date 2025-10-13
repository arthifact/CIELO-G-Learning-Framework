# 🎮 CIELO-G Learning Framework

A flexible, plug-and-play learning framework for **Godot 4** that enables rapid creation of educational mini-games with built-in progress tracking, certificate generation, and modular game systems.

## ✨ Features

- **🎯 Modular Game Systems**
  - Clickable System (multiple choice, selection-based games)
  - Drag-and-Drop System (sorting, matching, placement games)
  - Mix-and-Match System (connection-based, relationship games)

- **📊 Built-in Progress Tracking**
  - Automatic attempt counting
  - First-try success tracking
  - Retry functionality with certificate qualification
  - Progress indicators and feedback

- **🎓 Certificate Generation**
  - Automatic certificate generation for perfect runs
  - Player name customization
  - Thank you screen for incomplete runs

- **🎨 Rich Learning Experience**
  - Explanation/dialogue system with character expressions
  - Slide support for educational content
  - Rich text formatting (wave, shake, rainbow effects)
  - Scene transitions with dissolve effects

- **🔧 Easy to Extend**
  - Clean, modular architecture
  - Consistent commenting style
  - Well-documented code
  - Plug-and-play minigame integration

## 🚀 Quick Start

### Prerequisites
- Godot 4.x or later

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/CIELO-G_Learning_Framework.git
   ```

2. **Open in Godot:**
   - Open Godot 4
   - Click "Import"
   - Navigate to the cloned folder
   - Select `project.godot`
   - Click "Import & Edit"

3. **Run the project:**
   - Press `F5` or click the "Play" button

## 📝 Creating Your First Minigame

### 1. Choose a Game System

The framework provides three ready-to-use game systems:

#### Clickable System (`S_Clickable/`)
Perfect for: Multiple choice questions, selection-based games

#### Drag-and-Drop System (`S_DragAndDrop/`)
Perfect for: Sorting tasks, categorization, placement puzzles

#### Mix-and-Match System (`S_MixAndMatch/`)
Perfect for: Relationship matching, connection puzzles

### 2. Add Your Minigame

Edit `Global/Scripts/Managers/ModuleManager.gd`:

```gdscript
# ════════════════════════════════════════════════════════════
# START EDIT HERE
# ════════════════════════════════════════════════════════════

const MINIGAMES: Array[String] = [
    "res://Module/Play/YourGame/your_game.tscn",
    # Add more minigames here
]

# ════════════════════════════════════════════════════════════
# END EDIT HERE
# ════════════════════════════════════════════════════════════
```

### 3. Customize Learning Content

Edit `Module/Learn/ExplanationSystem.gd` to add your educational dialogue:

```gdscript
var dialogue_items: Array[Dictionary] = [
    {
        "expression": expressions["happy"],
        "text": "Welcome to the learning module!",
        "character": bodies["kat"]
    },
    # Add more dialogue...
]
```

## 📁 Project Structure

```
CIELO-G_Learning_Framework/
├── Global/                    # Shared resources and scripts
│   ├── Assets/               # Fonts, audio, characters, themes
│   └── Scripts/              
│       ├── Managers/         # Core game management
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
│   └── Certificate/          # Certificate generation
│
├── S_Clickable/              # Clickable game system
├── S_DragAndDrop/            # Drag-and-drop game system
└── S_MixAndMatch/            # Mix-and-match game system
```

## 🎯 Game System APIs

### Clickable System

```gdscript
# In your clickable object
@export var is_correct: bool = false  # Mark as correct answer
```

### Drag-and-Drop System

```gdscript
# In your source (drop zone)
@export var draggables_inside: Array[Area2D] = []  # Expected objects
```

### Mix-and-Match System

```gdscript
# In your match object
@export var answers: Array[Area2D] = []      # Correct connections
@export var max_outgoing: int = 1            # Max connections from this
@export var max_incoming: int = 1            # Max connections to this
```

## 🎨 Customization

### Themes
Located in `Global/Assets/Theme/`:
- `explanation.theme` - Learning module theme
- `mini_menu.theme` - Menu bar theme

### Characters & Expressions
Add your own in `Global/Assets/Characters/` and `Global/Assets/Expressions/`

### Audio
Place sound effects in `Global/Assets/Audio/SFX/` and voice files in `Global/Assets/Audio/Voice/`

## 🔧 Advanced Configuration

### Certificate Requirements

Certificates are awarded when:
- All minigames are completed
- All passed on the first attempt
- No retries were used

Modify this logic in `ModuleManager.gd`:

```gdscript
func _finish_run() -> void:
    var total: int = MINIGAMES.size()
    var perfect_run: bool = (_first_try_successes == total) and (not _used_retry)
    if perfect_run:
        _change(CERTIFICATE_SCENE)
    else:
        _change(THANK_YOU_SCENE)
```

### Progress Tracking

The `ModuleManager` automatically tracks:
- Attempts per minigame
- First-try successes
- Retry usage
- Completion count

## 🤝 Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for bugs and feature requests.

## 📄 License

This project is available for educational and commercial use. Please provide attribution when using this framework.

## 🙏 Acknowledgments

- Audio assets from [Kenney.nl](https://kenney.nl)
- Built with [Godot Engine](https://godotengine.org)

## 📧 Support

If you encounter any issues or have questions:
- Open an issue on GitHub
- Check the code documentation (all scripts are well-commented)

## 🎓 Educational Use

This framework was designed specifically for creating educational content and serious games. It has been used by educators and developers worldwide to create engaging learning experiences.

---

**Made with ❤️ for educators and game developers using Godot 4**
