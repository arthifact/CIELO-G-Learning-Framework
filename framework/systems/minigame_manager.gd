class_name MinigameManager
extends Node
# Base class for the three systems. Each one overrides _has_answer() and _is_correct().

const GROUP := &"minigame_objects"

var game_over := false

@onready var bar: MinigameBar = $"../Canvas/MinigameBar"


func _ready() -> void:
	bar.check_requested.connect(_on_check_requested)
	_setup.call_deferred()


func get_objects(type: Script) -> Array:
	return get_tree().get_nodes_in_group(GROUP).filter(func(node: Node) -> bool:
		return is_instance_of(node, type))


func select_object(_object: InteractiveObject) -> void:
	pass


func _setup() -> void:
	for object: InteractiveObject in get_objects(InteractiveObject):
		object.manager = self


func _has_answer() -> bool:
	return true


func _is_correct() -> bool:
	return false


func _on_check_requested() -> void:
	if game_over:
		return
	if not _has_answer():
		bar.show_invalid()
		return
	game_over = true
	var passed := _is_correct()
	ModuleManager.submit_minigame_result(passed)
	bar.show_result(passed)
