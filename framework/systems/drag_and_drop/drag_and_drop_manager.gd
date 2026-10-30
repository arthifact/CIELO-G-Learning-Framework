class_name DragAndDropManager
extends MinigameManager
# Pass when no draggable is in the wrong zone, and every zone has all of its
# answers (require_all_correct) or at least one of them.

@export var require_all_correct := true

var is_dragging := false

var _selected: Draggable


func select_object(object: InteractiveObject) -> void:
	if _selected:
		_selected.set_selected(false)
	_selected = object as Draggable
	_selected.set_selected(true)


func _has_answer() -> bool:
	for draggable: Draggable in get_objects(Draggable):
		if draggable.current_zone:
			return true
	return false


func _is_correct() -> bool:
	var draggables := get_objects(Draggable)
	for zone: DropZone in get_objects(DropZone):
		var inside := draggables.filter(func(d: Draggable) -> bool: return d.current_zone == zone)
		for draggable in inside:
			if draggable not in zone.answers:
				return false
		if require_all_correct and inside.size() != zone.answers.size():
			return false
		if inside.is_empty() and not zone.answers.is_empty():
			return false
	return true
