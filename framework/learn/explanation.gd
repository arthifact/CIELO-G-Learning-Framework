extends Control

const CHARACTERS_DIR := "res://assets/characters/"
const EXPRESSIONS_DIR := "res://assets/expressions/"
const LETTERS_PER_SECOND := 30.0

var _index := 0
var _typing: Tween

@onready var _progress: Label = $Progress
@onready var _text: RichTextLabel = %RichTextLabel
@onready var _next_button: Button = %NextButton
@onready var _prev_button: Button = %PrevButton
@onready var _voice: AudioStreamPlayer = %Voice
@onready var _body: TextureRect = %Body
@onready var _expression: TextureRect = %Expression
@onready var _slide: TextureRect = %Slide


func _ready() -> void:
	_next_button.pressed.connect(_on_next_pressed)
	_prev_button.pressed.connect(_on_prev_pressed)
	if Module.DIALOGUE.is_empty():
		ModuleManager.go_menu()
		return
	_show_line(1)


func _on_next_pressed() -> void:
	if _is_typing():
		_finish_typing()
	elif _index < Module.DIALOGUE.size() - 1:
		_index += 1
		_show_line(1)
	else:
		ModuleManager.go_menu()


func _on_prev_pressed() -> void:
	if _is_typing():
		_finish_typing()
	elif _index > 0:
		_index -= 1
		_show_line(-1)


# direction is 1 when going forward and -1 when going back.
func _show_line(direction: int) -> void:
	_finish_typing()
	var line: Dictionary = Module.DIALOGUE[_index]
	var is_slide := line.has("slide")

	_body.visible = not is_slide
	_text.visible = not is_slide
	_slide.visible = is_slide

	if is_slide:
		_slide.texture = line["slide"]
		_slide_in(_slide, direction)
	else:
		_body.texture = _load_png(CHARACTERS_DIR, line.get("character", ""))
		_expression.texture = _load_png(EXPRESSIONS_DIR, line.get("expression", ""))
		_slide_in(_body, direction)
		_type(line.get("text", ""))

	_prev_button.disabled = _index == 0
	_next_button.text = "Finish" if _index == Module.DIALOGUE.size() - 1 else "Next"
	_progress.text = "%d / %d" % [_index + 1, Module.DIALOGUE.size()]


func _type(bbcode: String) -> void:
	_text.text = bbcode
	_text.visible_ratio = 0.0
	var duration := bbcode.length() / LETTERS_PER_SECOND
	_typing = create_tween()
	_typing.tween_property(_text, "visible_ratio", 1.0, duration)
	_typing.finished.connect(_voice.stop)

	# Start the voice at a random spot so lines don't all sound the same.
	if _voice.stream:
		_voice.play(randf() * maxf(0.0, _voice.stream.get_length() - duration))


func _is_typing() -> bool:
	return _typing != null and _typing.is_running()


func _finish_typing() -> void:
	if _typing:
		_typing.kill()
		_typing = null
	_text.visible_ratio = 1.0
	_voice.stop()


func _slide_in(node: Control, direction: int) -> void:
	node.position.x = get_viewport_rect().size.x / 7.0 * direction
	node.modulate.a = 0.0
	var tween := create_tween().set_parallel().set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "position:x", 0.0, 0.3)
	tween.tween_property(node, "modulate:a", 1.0, 0.3)


func _load_png(dir: String, file_name: String) -> Texture2D:
	var path := dir + file_name + ".png"
	if not ResourceLoader.exists(path):
		push_warning("Missing image: " + path)
		return null
	return load(path)
