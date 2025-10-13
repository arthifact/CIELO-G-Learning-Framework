extends Button

@onready var line_edit: LineEdit = $"../LineEdit"

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if line_edit.text.strip_edges() == "":
		_shake_line_edit()
	else:
		ModuleManager.set_player_name(line_edit.text)
		SceneTransition.change_scene("res://Module/Certificate/certificate.tscn")

func _shake_line_edit() -> void:
	var tween := create_tween()
	var original_pos: Vector2 = line_edit.position
	var offset := 10

	tween.tween_property(line_edit, "position", original_pos + Vector2(-offset, 0), 0.05)
	tween.tween_property(line_edit, "position", original_pos + Vector2(offset, 0), 0.1)
	tween.tween_property(line_edit, "position", original_pos, 0.05)
