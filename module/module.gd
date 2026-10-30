class_name Module
# Your lesson. This is the only script you need to edit.

# Lines shown in Learn, in order.
# character / expression: PNG names in assets/characters and assets/expressions.
# text: supports BBCode like [wave], [shake] and [rainbow].
# slide: an image shown full screen instead of a character.
const DIALOGUE: Array[Dictionary] = [
	{"character": "kat", "expression": "regular", "text": "This is a simple line of dialogue."},
	{"character": "kat", "expression": "regular", "text": "This text has a [wave]wavy[/wave] effect."},
	{"character": "kat", "expression": "regular", "text": "This text is [shake]shaking[/shake]!"},
	{"character": "kat", "expression": "happy", "text": "[tornado freq=2.5][rainbow val=1.0]So colorful![/rainbow][/tornado]"},
	{"character": "maya", "expression": "regular", "text": "Hello! I'm a different character now."},
	{"character": "leo", "expression": "sad", "text": "And I'm another one. Now I feel a little sad..."},
	{"slide": preload("res://module/slides/sample.png")},
	{"character": "kat", "expression": "happy", "text": "All these features can be [wave]combined[/wave], but this sample shows one at a time!"},
]

# Minigame scenes played in Play, in random order.
const MINIGAMES: Array[String] = [
	"res://module/minigames/clickable_example/clickable_example.tscn",
	"res://module/minigames/drag_and_drop_example/drag_and_drop_example.tscn",
	"res://module/minigames/mix_and_match_example/mix_and_match_example.tscn",
]
