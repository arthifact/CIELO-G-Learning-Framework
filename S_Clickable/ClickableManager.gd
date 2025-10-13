# ClickableManager.gd
extends Node

@export var multiple_choice: bool = false

@onready var color_rect: ColorRect = $"../Canvas/Control/ColorRect"
@onready var label: Label = $"../Canvas/Control/Label"
@onready var next_button: Button = $"../Canvas/Control/Next"
@onready var retry_button: Button = $"../Canvas/Control/Retry"

var objects: Array = []
var selected_objects: Array[Area2D] = []
var game_over := false
var _submitted := false  # ensures submit_minigame_result called once per round

func _ready() -> void:
	next_button.text = "Check"
	next_button.disabled = false
	retry_button.disabled = true
	next_button.pressed.connect(_on_next_button_pressed)
	retry_button.pressed.connect(_on_retry_button_pressed)
	call_deferred("_init_objects")

func _init_objects() -> void:
	objects = get_tree().get_nodes_in_group("object_clickable")
	for object in objects:
		object.set_level_manager(self)

func select_object(object: Area2D) -> void:
	if game_over:
		return
	if object in selected_objects:
		selected_objects.erase(object)
		object.set_selected(false)
	else:
		if not multiple_choice:
			for other in selected_objects:
				other.set_selected(false)
			selected_objects.clear()
		selected_objects.append(object)
		object.set_selected(true)

func _on_next_button_pressed() -> void:
	# After result shown, "Next" advances to next minigame
	if game_over and next_button.text == "Next":
		ModuleManager.play_next_minigame()
		return

	# If we already evaluated this round, ignore extra clicks on "Check"
	if _submitted:
		return

	# Normal "Check" flow
	if selected_objects.is_empty():
		_show_feedback("Please select an option.", Color.BEIGE, "invalid")
		return

	game_over = true
	_submitted = true

	var all_selected_correct := true
	for obj in selected_objects:
		if not obj.is_correct:
			all_selected_correct = false
			break

	var total_correct := _count_total_correct_boxes()
	var passed := all_selected_correct and selected_objects.size() == total_correct

	# Report exactly once per round
	if ModuleManager.has_method("submit_minigame_result"):
		ModuleManager.submit_minigame_result(passed)

	if passed:
		_show_feedback("Correct!", Color.GREEN_YELLOW, "correct")
		next_button.text = "Next"
		next_button.disabled = false
		retry_button.disabled = true
	else:
		_show_feedback("Wrong!", Color.CRIMSON, "wrong")
		next_button.text = "Next"
		next_button.disabled = false
		retry_button.disabled = false

func _count_total_correct_boxes() -> int:
	var total := 0
	for object in objects:
		if object.is_correct:
			total += 1
	return total

func _on_retry_button_pressed() -> void:
	if ModuleManager.has_method("retry"):
		ModuleManager.retry()
	# On reload, the scene resets; these flags are refreshed by _ready()

func _show_feedback(text: String, color: Color, sound_type: String) -> void:
	label.text = text
	color_rect.color = color
	# Optional: if button has this method
	if next_button.has_method("play_feedback"):
		next_button.call("play_feedback", sound_type)
