class_name Draggable
extends InteractiveObject

@export var snap_on_drop := false
@export var return_to_origin := false

var current_zone: DropZone

var _dragging := false
var _drag_offset := Vector2.ZERO
var _origin := Vector2.ZERO
var _mouse := Vector2.ZERO


func _ready() -> void:
	super()
	_origin = global_position


# Track the mouse here so moves and releases are never missed, even off the object.
func _input(event: InputEvent) -> void:
	var mouse := event as InputEventMouse
	if mouse == null:
		return
	_mouse = get_canvas_transform().affine_inverse() * mouse.position
	if not _dragging:
		return
	if mouse is InputEventMouseMotion:
		global_position = _mouse - _drag_offset
	elif mouse is InputEventMouseButton and not mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT:
		_stop_dragging()


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	var drag_manager := manager as DragAndDropManager
	if not _is_left_press(event) or drag_manager == null or drag_manager.game_over:
		return
	if drag_manager.is_dragging or not _is_on_top():
		return
	drag_manager.is_dragging = true
	_dragging = true
	_drag_offset = _mouse - global_position
	get_parent().move_child(self, -1)
	_play_click()
	drag_manager.select_object(self)


func _stop_dragging() -> void:
	_dragging = false
	(manager as DragAndDropManager).is_dragging = false
	set_selected(false)
	await get_tree().physics_frame  # let overlaps catch up with the last move
	current_zone = null
	for area in get_overlapping_areas():
		if area is DropZone:
			current_zone = area
			break
	if current_zone and snap_on_drop:
		global_position = current_zone.global_position
	elif current_zone == null and return_to_origin:
		global_position = _origin


# When draggables overlap, only the top one is picked up.
func _is_on_top() -> bool:
	var query := PhysicsPointQueryParameters2D.new()
	query.position = _mouse
	query.collide_with_areas = true
	var top: Draggable = null
	for hit in get_world_2d().direct_space_state.intersect_point(query, 32):
		var draggable := hit["collider"] as Draggable
		if draggable and (top == null or draggable.get_index() > top.get_index()):
			top = draggable
	return top == self
