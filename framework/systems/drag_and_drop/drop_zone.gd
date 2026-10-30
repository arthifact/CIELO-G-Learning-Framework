class_name DropZone
extends Area2D

# The draggables that belong in this zone. Leave empty if it should stay empty.
@export var answers: Array[Draggable] = []


func _enter_tree() -> void:
	add_to_group(MinigameManager.GROUP)
