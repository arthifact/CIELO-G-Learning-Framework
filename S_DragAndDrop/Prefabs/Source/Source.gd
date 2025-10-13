extends Area2D

@export var draggables_inside: Array[Area2D] = []

var level_manager: Node = null

func _enter_tree() -> void:
	add_to_group("object_sources")

func set_level_manager(manager: Node) -> void:
	level_manager = manager
