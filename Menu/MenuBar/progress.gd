extends Label

func _ready() -> void:
	text = ModuleManager.get_progress_text()
