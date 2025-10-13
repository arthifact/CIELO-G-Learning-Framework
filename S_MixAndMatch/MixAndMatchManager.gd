# MixAndMatchManager.gd
extends Node

@export var require_all_correct := false

@onready var line_layer: Node2D     = $"../Objects/LineLayer"
@onready var color_rect: ColorRect  = $"../Canvas/Control/ColorRect"
@onready var label: Label           = $"../Canvas/Control/Label"
@onready var next_button: Button    = $"../Canvas/Control/Next"
@onready var retry_button: Button   = $"../Canvas/Control/Retry"

var objects: Array = []
var selected_objects: Array[Area2D] = []
var connections: Array[Dictionary] = []
var outgoing_count: Dictionary[Area2D, int] = {}
var incoming_count: Dictionary[Area2D, int] = {}
var game_over := false
var _submitted := false  # ensure we notify ModuleManager exactly once

const LINE_WIDTH := 6
const LINE_COLOR := Color.BLACK

# ════════════════════════════════════════════════════════════
# Lifecycle
# ════════════════════════════════════════════════════════════
func _ready() -> void:
	next_button.text = "Check"
	next_button.disabled = false
	next_button.pressed.connect(_on_next_button_pressed)

	retry_button.disabled = true
	retry_button.pressed.connect(_on_retry_button_pressed)

	call_deferred("_init_objects")

func _init_objects() -> void:
	objects = get_tree().get_nodes_in_group("object_match")
	for obj in objects:
		obj.set_level_manager(self)
		outgoing_count[obj] = 0
		incoming_count[obj] = 0

# ════════════════════════════════════════════════════════════
# Public
# ════════════════════════════════════════════════════════════
func select_object(object: Area2D) -> void:
	if game_over:
		return

	if selected_objects.is_empty():
		var used    = outgoing_count[object]
		var allowed = object.get_max_outgoing()
		var hasAny  = _has_any_connection_for(object)

		if used >= allowed and not hasAny:
			return
		selected_objects.append(object)
		object.set_selected(true)
		return

	var first = selected_objects[0]

	if object == first:
		first.set_selected(false)
		selected_objects.clear()
		return

	if _has_connection(first, object):
		_remove_connection(first, object)
	elif _has_connection(object, first):
		_remove_connection(object, first)
	else:
		if object not in first.options:
			first.set_selected(false)
			selected_objects.clear()
			select_object(object)
			return

		if outgoing_count[first] >= first.get_max_outgoing():
			_remove_outgoing_for(first)

		if incoming_count[object] >= object.get_max_incoming():
			_remove_incoming_for(object)

		var line = _draw_connection(first, object)
		_register_connection(first, object, line)

	first.set_selected(false)
	object.set_selected(false)
	selected_objects.clear()

# ════════════════════════════════════════════════════════════
# Connection helpers
# ════════════════════════════════════════════════════════════
func _has_any_connection_for(a: Area2D) -> bool:
	for c in connections:
		if c["from"] == a or c["to"] == a:
			return true
	return false

func _has_connection(a: Area2D, b: Area2D) -> bool:
	for c in connections:
		if c["from"] == a and c["to"] == b:
			return true
	return false

func _remove_connection(a: Area2D, b: Area2D) -> void:
	for c in connections:
		if c["from"] == a and c["to"] == b:
			c["line"].queue_free()
			outgoing_count[a] -= 1
			incoming_count[b] -= 1
			connections.erase(c)
			return

func _remove_outgoing_for(a: Area2D) -> void:
	var to_remove: Array = []
	for c in connections:
		if c["from"] == a:
			to_remove.append(c)
	for c in to_remove:
		c["line"].queue_free()
		outgoing_count[c["from"]] -= 1
		incoming_count[c["to"]] -= 1
		connections.erase(c)

func _remove_incoming_for(b: Area2D) -> void:
	var to_remove: Array = []
	for c in connections:
		if c["to"] == b:
			to_remove.append(c)
	for c in to_remove:
		c["line"].queue_free()
		outgoing_count[c["from"]] -= 1
		incoming_count[c["to"]] -= 1
		connections.erase(c)

func _draw_connection(from_object: Area2D, to_object: Area2D) -> Line2D:
	var line := Line2D.new()
	line.width = LINE_WIDTH
	line.default_color = LINE_COLOR
	line.add_point(from_object.get_node("Pivot").global_position)
	line.add_point(to_object.get_node("Pivot").global_position)
	line_layer.add_child(line)
	return line

func _register_connection(a: Area2D, b: Area2D, line: Line2D) -> void:
	connections.append({ "from": a, "to": b, "line": line })
	outgoing_count[a] += 1
	incoming_count[b] += 1

# ════════════════════════════════════════════════════════════
# Match Checking (based on object.answers)
# ════════════════════════════════════════════════════════════
func is_connection_correct(a: Area2D, b: Area2D) -> bool:
	return a.is_answer_correct(b) or b.is_answer_correct(a)

# ════════════════════════════════════════════════════════════
# Feedback (Visual & Sound)
# ════════════════════════════════════════════════════════════
func _show_feedback(text: String, color: Color, sound_type: String) -> void:
	label.text = text
	color_rect.color = color
	if next_button.has_method("play_feedback"):
		next_button.call("play_feedback", sound_type)

# ════════════════════════════════════════════════════════════
# Logic / Validation
# ════════════════════════════════════════════════════════════
func _on_next_button_pressed() -> void:
	# After validation, "Next" advances regardless of pass/fail.
	if game_over and next_button.text == "Next":
		ModuleManager.play_next_minigame()
		return
	if game_over:
		return

	# Prevent double submits
	if _submitted:
		return

	if connections.is_empty():
		_show_feedback("Please select an option.", Color.BEIGE, "invalid")
		return

	var all_correct := true
	var matched := {}

	for c in connections:
		var a = c["from"]
		var b = c["to"]

		if not is_connection_correct(a, b):
			all_correct = false
			break

		if not matched.has(a): matched[a] = []
		matched[a].append(b)

		if not matched.has(b): matched[b] = []
		matched[b].append(a)

	if all_correct:
		for object in objects:
			if object.answers.is_empty():
				continue
			if not matched.has(object):
				all_correct = false
				break

			var matches = matched[object]

			if require_all_correct:
				if not object.answers.all(func(ans): return ans in matches):
					all_correct = false
					break
			else:
				if not matches.any(func(other): return other in object.answers):
					all_correct = false
					break

	var passed := all_correct
	game_over = true
	_submitted = true

	# Notify ModuleManager exactly once
	if ModuleManager.has_method("submit_minigame_result"):
		ModuleManager.submit_minigame_result(passed)

	if passed:
		_show_feedback("Correct!", Color.LIGHT_GREEN, "correct")
		next_button.text = "Next"
		next_button.disabled = false
		retry_button.disabled = true
	else:
		_show_feedback("Wrong!", Color.INDIAN_RED, "wrong")
		next_button.text = "Next"
		next_button.disabled = false
		retry_button.disabled = false

# ════════════════════════════════════════════════════════════
# Retry
# ════════════════════════════════════════════════════════════
func _on_retry_button_pressed() -> void:
	if ModuleManager.has_method("retry"):
		ModuleManager.retry()
