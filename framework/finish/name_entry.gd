extends Button

@onready var _name_field: LineEdit = $"../LineEdit"
@onready var _field_origin := _name_field.position


func _ready() -> void:
	pressed.connect(_on_pressed)
	_name_field.text_submitted.connect(_on_pressed.unbind(1))


func _on_pressed() -> void:
	var player_name := _name_field.text.strip_edges()
	if player_name == "":
		_shake_name_field()
		return
	ModuleManager.player_name = player_name
	ModuleManager.show_certificate()


func _shake_name_field() -> void:
	var origin := _field_origin
	var tween := create_tween()
	tween.tween_property(_name_field, "position", origin + Vector2(-10, 0), 0.05)
	tween.tween_property(_name_field, "position", origin + Vector2(10, 0), 0.1)
	tween.tween_property(_name_field, "position", origin, 0.05)
