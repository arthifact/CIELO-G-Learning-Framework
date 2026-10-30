extends Area2D

enum Action { LEARN, PLAY }

const HOVER_SCALE := Vector2(1.05, 1.05)
const CLICK_SCALE := Vector2(1.1, 1.1)

@export var action := Action.LEARN

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _sfx: AudioStreamPlayer2D = $AudioStreamPlayer2D


func _ready() -> void:
	mouse_entered.connect(_scale_to.bind(HOVER_SCALE))
	mouse_exited.connect(_scale_to.bind(Vector2.ONE))
	input_event.connect(_on_input_event)


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	var mouse := event as InputEventMouseButton
	if mouse == null or not mouse.pressed or mouse.button_index != MOUSE_BUTTON_LEFT:
		return
	_sfx.play()
	var tween := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(_sprite, "scale", CLICK_SCALE, 0.08)
	tween.tween_property(_sprite, "scale", Vector2.ONE, 0.08)
	if action == Action.LEARN:
		ModuleManager.start_explanation()
	else:
		ModuleManager.start_games()


func _scale_to(target: Vector2) -> void:
	create_tween().tween_property(_sprite, "scale", target, 0.1)
