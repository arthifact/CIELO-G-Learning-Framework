class_name InteractiveObject
extends Area2D
# Base class for clickables, draggables and matchables.
# Needs a CanvasGroup/Sprite2D child and an AudioStreamPlayer2D child.

const OUTLINE_SHADER := preload("res://assets/shaders/group_outline.gdshader")

@export var outline_color := Color.BLACK

var manager: MinigameManager

@onready var _outline: CanvasGroup = $CanvasGroup
@onready var _sprite: Sprite2D = $CanvasGroup/Sprite2D
@onready var _sfx: AudioStreamPlayer2D = $AudioStreamPlayer2D


func _enter_tree() -> void:
	add_to_group(MinigameManager.GROUP)


func _ready() -> void:
	var outline_material := ShaderMaterial.new()
	outline_material.shader = OUTLINE_SHADER
	outline_material.set_shader_parameter("line_color", outline_color)
	_outline.material = outline_material
	set_selected(false)

	mouse_entered.connect(_scale_to.bind(Vector2(1.025, 1.025)))
	mouse_exited.connect(_scale_to.bind(Vector2.ONE))
	input_event.connect(_on_input_event)


func set_selected(selected: bool) -> void:
	_outline.material.set_shader_parameter("line_thickness", 4.0 if selected else 1.0)


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if _is_left_press(event) and manager and not manager.game_over:
		_play_click()
		manager.select_object(self)


func _is_left_press(event: InputEvent) -> bool:
	var mouse := event as InputEventMouseButton
	return mouse != null and mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT


func _play_click() -> void:
	_sfx.play()
	var tween := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(_sprite, "scale", Vector2(1.05, 1.05), 0.08)
	tween.tween_property(_sprite, "scale", Vector2.ONE, 0.08)


func _scale_to(target: Vector2) -> void:
	create_tween().tween_property(_sprite, "scale", target, 0.1)
