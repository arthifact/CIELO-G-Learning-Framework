extends Control

var expressions := {
	"happy":   preload("res://Global/Assets/Expressions/emotion_happy.png"),
	"regular": preload("res://Global/Assets/Expressions/emotion_regular.png"),
	"sad":     preload("res://Global/Assets/Expressions/emotion_sad.png"),
	"angry":   preload("res://Global/Assets/Expressions/emotion_angry.png")
}

var bodies := {
	"kat":    preload("res://Global/Assets/Characters/kat.png"),
	"sophia": preload("res://Global/Assets/Characters/sophia.png"),
	"pink":   preload("res://Global/Assets/Characters/pink.png")
}

# ════════════════════════════════════════════════════════════
# START EDIT HERE
# ════════════════════════════════════════════════════════════

var dialogue_items: Array[Dictionary] = [
	# Simple text
	{
		"expression": expressions["regular"],
		"text": "This is a simple line of dialogue.",
		"character": bodies["kat"]
	},

	# Text with wave effect
	{
		"expression": expressions["regular"],
		"text": "This text has a [wave]wavy[/wave] effect.",
		"character": bodies["kat"]
	},

	# Text with shake effect
	{
		"expression": expressions["regular"],
		"text": "This text is [shake]shaking[/shake]!",
		"character": bodies["kat"]
	},

	# Text with rainbow and tornado effects
	{
		"expression": expressions["happy"],
		"text": "[tornado freq=2.5][rainbow val=1.0]So colorful![/rainbow][/tornado]",
		"character": bodies["kat"]
	},

	# Character change
	{
		"expression": expressions["regular"],
		"text": "Hello! I'm a different character now.",
		"character": bodies["sophia"]
	},

	# Expression change
	{
		"expression": expressions["sad"],
		"text": "Now I feel a little sad...",
		"character": bodies["sophia"]
	},

	# Slides, No text will be shown
	{ 
		"expression": expressions["happy"],
		"text": "",
		"character": bodies["kat"],
		"image": preload("res://Module/Learn/Slides/sample.png")
	},

	# Final line
	{
		"expression": expressions["happy"],
		"text": "All these features can be [wave]combined[/wave], but this sample shows one at a time!",
		"character": bodies["kat"]
	}
]

# ════════════════════════════════════════════════════════════
# END EDIT HERE
# ════════════════════════════════════════════════════════════

var current_item_index: int = 0

@onready var progress: Label = $Progress
@onready var rich_text_label: RichTextLabel          = %RichTextLabel
@onready var next_button: Button                     = %NextButton
@onready var prev_button: Button                     = %PrevButton
@onready var audio_stream_player: AudioStreamPlayer  = %AudioStreamPlayer
@onready var body: TextureRect                       = %Body
@onready var expression: TextureRect                 = %Expression
@onready var extra_image: TextureRect                = %Image

var _text_tween: Tween = null
var _current_has_image: bool = false

const DIR_RIGHT := 1   # enter from right (Next)
const DIR_LEFT  := -1  # enter from left  (Prev)

func _ready() -> void:
	next_button.pressed.connect(advance)
	prev_button.pressed.connect(go_back)
	_update_nav_buttons()
	show_text(DIR_RIGHT)

func show_text(dir: int = DIR_RIGHT) -> void:
	_kill_text_tween()
	if audio_stream_player.playing:
		audio_stream_player.stop()

	var item: Dictionary = dialogue_items[current_item_index]
	var text: String = String(item.get("text", ""))
	_current_has_image = item.has("image") and item["image"] != null

	# Prepare text
	rich_text_label.clear()
	rich_text_label.bbcode_enabled = true
	rich_text_label.append_text(text)
	rich_text_label.visible_ratio = 0.0

	# Character / label visibility
	var show_char := not _current_has_image
	body.visible = show_char
	expression.visible = show_char
	rich_text_label.visible = show_char
	if show_char:
		body.texture = item["character"]
		expression.texture = item["expression"]
	else:
		extra_image.texture = item["image"]

	# Image starts hidden, offscreen depending on direction
	extra_image.visible = false
	extra_image.modulate.a = 0.0
	var vw := get_viewport_rect().size.x
	extra_image.position.x = vw if dir == DIR_RIGHT else -vw

	# Type-on tween
	var text_appearing_duration: float = float(text.length()) / 30.0
	_text_tween = create_tween()
	_text_tween.tween_property(rich_text_label, "visible_ratio", 1.0, text_appearing_duration)

	# Sound
	var sound_max_offset: float = audio_stream_player.stream.get_length() - text_appearing_duration
	var sound_start_position: float = max(0.0, randf() * max(0.0, sound_max_offset))
	audio_stream_player.play(sound_start_position)
	_text_tween.finished.connect(audio_stream_player.stop)

	# Slide-in character immediately; reveal image after text finishes
	if show_char:
		slide_in(dir)

	next_button.disabled = false
	_text_tween.finished.connect(func() -> void:
		next_button.disabled = false
		if _current_has_image:
			show_optional_image(dir)
	)

	_update_nav_buttons()

func advance() -> void:
	# If still revealing, complete instantly instead of advancing
	if _text_tween and _text_tween.is_valid() and rich_text_label.visible_ratio < 1.0:
		_skip_current_line()
		return

	current_item_index += 1
	if current_item_index >= dialogue_items.size():
		ModuleManager.go_menu()
		return
	show_text(DIR_RIGHT)

func go_back() -> void:
	# If still revealing, complete instantly instead of moving
	if _text_tween and _text_tween.is_valid() and rich_text_label.visible_ratio < 1.0:
		_skip_current_line()
		return

	current_item_index = max(0, current_item_index - 1)
	show_text(DIR_LEFT)

func show_optional_image(_dir: int) -> void:
	extra_image.visible = true
	var tw := create_tween().set_ease(Tween.EASE_OUT)
	tw.tween_property(extra_image, "position:x", 0.0, 0.3)
	tw.parallel().tween_property(extra_image, "modulate:a", 1.0, 0.3)

func slide_in(dir: int) -> void:
	var tw := create_tween().set_ease(Tween.EASE_OUT)
	var vw := get_viewport_rect().size.x
	body.position.x = (vw / 7.0) if dir == DIR_RIGHT else (-vw / 7.0)
	body.modulate.a = 0.0
	tw.tween_property(body, "position:x", 0.0, 0.3)
	tw.parallel().tween_property(body, "modulate:a", 1.0, 0.2)

func _skip_current_line() -> void:
	_kill_text_tween()
	if audio_stream_player.playing:
		audio_stream_player.stop()
	rich_text_label.visible_ratio = 1.0
	if _current_has_image:
		show_optional_image(DIR_RIGHT) # just reveal

func _kill_text_tween() -> void:
	if _text_tween and _text_tween.is_valid():
		_text_tween.kill()
	_text_tween = null

func _update_nav_buttons() -> void:
	prev_button.disabled = (current_item_index <= 0)
	
	progress.text = "%d / %d" % [current_item_index + 1, dialogue_items.size()]

	# Change Next button label to "Finish" on last item
	if current_item_index >= dialogue_items.size() - 1:
		next_button.text = "Finish"
	else:
		next_button.text = "Next"
