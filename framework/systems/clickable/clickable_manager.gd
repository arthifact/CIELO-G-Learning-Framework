extends MinigameManager
# Pass by selecting every correct Clickable and nothing else.

@export var multiple_choice := false

var _selected: Array[Clickable] = []


func select_object(object: InteractiveObject) -> void:
	var clickable := object as Clickable
	if clickable in _selected:
		_selected.erase(clickable)
		clickable.set_selected(false)
		return
	if not multiple_choice:
		for other in _selected:
			other.set_selected(false)
		_selected.clear()
	_selected.append(clickable)
	clickable.set_selected(true)


func _has_answer() -> bool:
	return not _selected.is_empty()


func _is_correct() -> bool:
	for clickable: Clickable in get_objects(Clickable):
		if clickable.is_correct != (clickable in _selected):
			return false
	return true
