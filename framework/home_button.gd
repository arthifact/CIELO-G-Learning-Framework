extends Button


func _ready() -> void:
	pressed.connect(ModuleManager.go_menu)
