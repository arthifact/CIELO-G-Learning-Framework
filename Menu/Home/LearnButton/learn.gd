# learn.gd

extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var sfx: AudioStreamPlayer2D = $AudioStreamPlayer2D

const NORMAL: Vector2 = Vector2.ONE
const HOVER:  Vector2 = Vector2(1.05, 1.05)
const CLICK:  Vector2 = Vector2(1.1, 1.1)

const T_FAST:  float = 0.10
const T_CLICK: float = 0.08

func _ready() -> void:
	sprite.scale = NORMAL
	mouse_entered.connect(func() -> void: _tween_to(HOVER, T_FAST))
	mouse_exited.connect(func() -> void: _tween_to(NORMAL, T_FAST))
	input_event.connect(_on_input_event)

func _on_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if sfx.stream:
			sfx.play()
		var t: Tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		t.tween_property(sprite, "scale", CLICK,  T_CLICK)
		t.tween_property(sprite, "scale", NORMAL, T_CLICK)
		ModuleManager.start_explanation()

func _tween_to(target: Vector2, duration: float) -> void:
	create_tween().tween_property(sprite, "scale", target, duration)
