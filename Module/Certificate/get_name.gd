extends Label

func _ready() -> void:
	# Grab the stored name from ModuleManager
	var player_name: String = ModuleManager.get_player_name()

	# Fallback if no name was set
	if player_name.strip_edges() == "":
		player_name = "Player"

	# Set text to show on the certificate
	text = player_name
