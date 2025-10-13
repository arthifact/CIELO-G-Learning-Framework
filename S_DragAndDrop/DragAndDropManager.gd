# DragAndDropManager.gd
extends Node

@export var require_all_correct: bool = true

@onready var color_rect: ColorRect = $"../Canvas/Control/ColorRect"
@onready var label: Label = $"../Canvas/Control/Label"
@onready var next_button: Button = $"../Canvas/Control/Next"
@onready var retry_button: Button = $"../Canvas/Control/Retry"

var objects: Array = []
var sources: Array = []

var is_mouse_busy: bool = false
var selected_objects: Array[Area2D] = []
var game_over := false
var _submitted := false  # ensure submit_minigame_result is called once per round

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
	objects = get_tree().get_nodes_in_group("object_draggable")
	sources = get_tree().get_nodes_in_group("object_sources")

	for object in objects:
		object.set_level_manager(self)

	for source in sources:
		source.set_level_manager(self)

# ════════════════════════════════════════════════════════════
# Public
# ════════════════════════════════════════════════════════════
func select_object(object: Area2D) -> void:
	if game_over:
		return

	for other in selected_objects:
		other.set_selected(false)
	selected_objects.clear()

	object.set_selected(true)
	selected_objects.append(object)

# ════════════════════════════════════════════════════════════
# Logic / Validation
# ════════════════════════════════════════════════════════════
func _on_next_button_pressed() -> void:
	# After result, "Next" advances to next minigame
	if game_over and next_button.text == "Next":
		ModuleManager.play_next_minigame()
		return
	if game_over:
		return

	# Avoid double-submit spam on "Check"
	if _submitted:
		return

	# Guard: make sure at least one item is placed somewhere
	if objects.is_empty() or sources.is_empty():
		_show_feedback("Nothing to validate.", Color.BEIGE, "invalid")
		return

	var any_placed := false
	for obj in objects:
		if obj.current_source != null:
			any_placed = true
			break

	if not any_placed:
		_show_feedback("Nothing to validate.", Color.BEIGE, "invalid")
		return

	# Validate placements
	var all_correct := true

	for source in sources:
		var expected_objects: Array = source.draggables_inside
		var actual_objects: Array = []
		for obj in objects:
			if obj.current_source == source:
				actual_objects.append(obj)

		if require_all_correct:
			# Every expected must be present, and no extra objects allowed
			for expected_obj in expected_objects:
				if not actual_objects.has(expected_obj):
					all_correct = false
					break
			if not all_correct:
				break
			for obj in actual_objects:
				if not expected_objects.has(obj):
					all_correct = false
					break
		else:
			# At least one correct in each source, and no wrong ones
			var found_one := false
			for obj in actual_objects:
				if expected_objects.has(obj):
					found_one = true
				else:
					all_correct = false
					break
			if not found_one:
				all_correct = false

		if not all_correct:
			break

	var passed := all_correct
	game_over = true
	_submitted = true

	# Report result exactly once
	if ModuleManager.has_method("submit_minigame_result"):
		ModuleManager.submit_minigame_result(passed)

	# Feedback + next/retry state
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
	# On scene reload, _ready() resets UI and flags; no manual resets needed here.

# ════════════════════════════════════════════════════════════
# Feedback (Visual & Sound)
# ════════════════════════════════════════════════════════════
func _show_feedback(text: String, color: Color, sound_type: String) -> void:
	label.text = text
	color_rect.color = color
	if next_button.has_method("play_feedback"):
		next_button.call("play_feedback", sound_type)
