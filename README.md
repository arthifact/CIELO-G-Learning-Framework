# CIELO-G Learning Framework

A Godot 4 framework for building short, gamified Earth Science lessons for grades 6–12. A lesson (a *module*) pairs an explanation, in which guide characters present animated dialogue and slides, with interactive minigames. Players get instant feedback and can retry any minigame, and passing every minigame on the first try earns a personalized certificate.

Developed in 2025 as undergraduate research at The University of Texas at El Paso (UTEP), supported by the U.S. National Science Foundation through CIELO-G (Award 2228180).

## Run

Open `project.godot` in [Godot 4.5+](https://godotengine.org) and press **F5**. To publish to the web (for example on itch.io), use **Project → Export → Web**, which writes to `build/web/`.

## Layout

```
module/      the lesson: module.gd, slides, minigames (edit this)
framework/   menu, explanation, certificate and the three interaction systems
assets/      art, audio, fonts, shaders and themes
```

## Add a module

1. **Explanation.** Edit `DIALOGUE` in `module/module.gd`. Each line names a character and an expression (PNG files in `assets/characters` and `assets/expressions`) plus BBCode text, or shows a full-screen `slide`.
2. **Minigames.** `module/minigames/` has one small example per system to copy. In the FileSystem dock, right-click a system scene and choose **New Inherited Scene**, then save it under `module/minigames/<name>/`:
   - `framework/systems/clickable/clickable_system.tscn`: select the right answer(s). Add `clickable.tscn` instances under `Objects` and tick `is_correct`.
   - `framework/systems/drag_and_drop/drag_and_drop_system.tscn`: sort items into zones. Add `draggable.tscn` and `drop_zone.tscn` instances, then list each zone's `answers`.
   - `framework/systems/mix_and_match/mix_and_match_system.tscn`: connect pairs with lines. Add `matchable.tscn` instances, then set `options`, `answers` and the line limits.

   Give each object a sprite and a collision shape, and set a background on `Canvas/Background`.
3. **Register.** Add each minigame's scene path to `MINIGAMES` in `module/module.gd`.

## Credits

Backgrounds, menu buttons and certificate designed in Canva. The characters, expressions and bubble pattern are original. Sound effects by [Kenney](https://kenney.nl) (CC0). Dialogue voice clip by [unicaegames](https://www.patreon.com/unicaegames). Fonts: [Outfit](https://github.com/Outfitio/Outfit-Fonts) and [Space Mono](https://github.com/googlefonts/spacemono), both under the [SIL Open Font License](assets/fonts/OFL.txt). Code released under the [MIT License](LICENSE).
