# CIELO-G Learning Framework

A Godot 4 framework for gamified Earth Science lessons, grades 6–12.

Each lesson has two parts: characters explain a topic, then students play short minigames. Finish every minigame on the first try to earn a certificate.

Undergraduate research at UTEP (2025), funded by the U.S. National Science Foundation through CIELO-G (Award 2228180).

## Run

Open `project.godot` in [Godot 4.5+](https://godotengine.org) and press **F5**.

## Make a lesson

Everything you edit is in `module/`.

1. **Explain.** Write the dialogue in `module/module.gd`.
2. **Play.** Copy an example from `module/minigames/`:
   - **Clickable:** pick the right answer.
   - **Drag and drop:** sort items into zones.
   - **Mix and match:** connect pairs.
3. **Add.** List each minigame in `MINIGAMES` in `module/module.gd`.

## Credits

Characters by Gabriel Alonso. Sounds by [Kenney](https://kenney.nl) and [unicaegames](https://www.patreon.com/unicaegames). Fonts under the [OFL](assets/fonts/OFL.txt). Code under the [MIT License](LICENSE).
