extends Label


func _ready() -> void:
	var player_name := ModuleManager.player_name.strip_edges()
	text = player_name if player_name != "" else "Player"
