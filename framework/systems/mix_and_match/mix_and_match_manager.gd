extends MinigameManager
# Click one object, then one of its options, to draw a line between them.
# Clicking a connected pair again removes the line.
# Pass when every line joins an answer pair and every object with answers is
# connected to all of them (require_all_correct) or at least one.

const LINE_WIDTH := 6.0
const LINE_COLOR := Color.BLACK

@export var require_all_correct := false

var _lines: Array[Dictionary] = []  # {"from": Matchable, "to": Matchable, "line": Line2D}
var _selected: Matchable

@onready var _line_layer: Node2D = $"../Objects/LineLayer"


func select_object(object: InteractiveObject) -> void:
	var target := object as Matchable

	if _selected == null:
		# A full object can still be picked, to remove one of its lines.
		if _count(target, "from") >= target.max_outgoing and not _has_line(target):
			return
		_selected = target
		target.set_selected(true)
		return

	var first := _selected
	first.set_selected(false)
	_selected = null
	if target == first:
		return

	var existing := _find(first, target)
	if existing.is_empty():
		existing = _find(target, first)
	if not existing.is_empty():
		_remove(existing)
	elif target in first.options:
		_remove_extra(first, "from", first.max_outgoing)
		_remove_extra(target, "to", target.max_incoming)
		_add(first, target)
	else:
		select_object(target)


func _has_answer() -> bool:
	return not _lines.is_empty()


func _is_correct() -> bool:
	var partners := {}
	for entry in _lines:
		var a: Matchable = entry["from"]
		var b: Matchable = entry["to"]
		if b not in a.answers and a not in b.answers:
			return false
		partners.get_or_add(a, []).append(b)
		partners.get_or_add(b, []).append(a)

	for object: Matchable in get_objects(Matchable):
		var connected: Array = partners.get(object, [])
		var found := object.answers.filter(func(answer: Matchable) -> bool: return answer in connected)
		if require_all_correct and found.size() < object.answers.size():
			return false
		if found.is_empty() and not object.answers.is_empty():
			return false
	return true


func _add(from: Matchable, to: Matchable) -> void:
	var line := Line2D.new()
	line.width = LINE_WIDTH
	line.default_color = LINE_COLOR
	line.add_point(_line_layer.to_local(from.pivot.global_position))
	line.add_point(_line_layer.to_local(to.pivot.global_position))
	_line_layer.add_child(line)
	_lines.append({"from": from, "to": to, "line": line})


func _remove(entry: Dictionary) -> void:
	entry["line"].queue_free()
	_lines.erase(entry)


# Frees up room for one more line at this end of the object.
func _remove_extra(object: Matchable, end: String, limit: int) -> void:
	for entry in _lines.filter(func(e: Dictionary) -> bool: return e[end] == object):
		if _count(object, end) < limit:
			return
		_remove(entry)


func _find(from: Matchable, to: Matchable) -> Dictionary:
	for entry in _lines:
		if entry["from"] == from and entry["to"] == to:
			return entry
	return {}


func _count(object: Matchable, end: String) -> int:
	return _lines.filter(func(e: Dictionary) -> bool: return e[end] == object).size()


func _has_line(object: Matchable) -> bool:
	return _lines.any(func(e: Dictionary) -> bool: return e["from"] == object or e["to"] == object)
