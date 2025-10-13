class_name DraggableObject
extends Area2D

@export var outline_color: Color = Color8(0, 0, 0)
@export var snap_on_drop: bool = false
@export var return_to_origin: bool = false

@onready var sprite: Sprite2D = $CanvasGroup/Sprite2D
@onready var sfx: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var outline_shader: CanvasGroup = $CanvasGroup

const OUTLINE_SHADER := preload("res://Global/Assets/Shaders/group_outline.gdshader")

var level_manager: Node = null
var is_dragging := false
var drag_offset := Vector2.ZERO
var current_source: Node = null
var original_position: Vector2
var original_parent: Node = null
var original_index: int = -1


# ════════════════════════════════════════════════════════════
# Lifecycle
# ════════════════════════════════════════════════════════════

func _enter_tree() -> void:
	add_to_group("object_draggable")

func _ready() -> void:
	var mat = ShaderMaterial.new()
	mat.shader = OUTLINE_SHADER
	outline_shader.material = mat

	original_position = global_position
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	_update_outline(false)
	_set_outline_color(outline_color)
	set_process(true)

func set_level_manager(manager: Node) -> void:
	level_manager = manager

# ════════════════════════════════════════════════════════════
# Drag Logic
# ════════════════════════════════════════════════════════════

func _process(_delta: float) -> void:
	if is_dragging:
		global_position = get_global_mouse_position() - drag_offset

func _on_input_event(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if not level_manager or level_manager.is_mouse_busy:
				return

			var mouse_pos = get_global_mouse_position()
			var params := PhysicsPointQueryParameters2D.new()
			params.position = mouse_pos
			params.collide_with_areas = true
			params.collision_mask = 1

			var all_hits = get_world_2d().direct_space_state.intersect_point(params, 32)

			# Filter only draggable objects
			var draggables := []
			for hit in all_hits:
				var col = hit["collider"]
				if col is DraggableObject:
					draggables.append(col)

			# Sort by child index (stacking order in scene)
			draggables.sort_custom(func(a, b): return a.get_index() < b.get_index())

			# Only topmost draggable (last one in parent) gets selected
			if draggables.is_empty() or draggables[-1] != self:
				return

			# ─── Begin Drag ───
			level_manager.is_mouse_busy = true
			get_parent().move_child(self, get_parent().get_child_count() - 1)

			_play_click_sound()
			_play_click_scale_animation()
			level_manager.select_object(self)
			is_dragging = true
			drag_offset = mouse_pos - global_position

		else:
			is_dragging = false
			if level_manager:
				level_manager.is_mouse_busy = false
			set_selected(false)
			_check_drop_target()



func _check_drop_target() -> void:
	if level_manager == null:
		current_source = null
		return

	var overlapping = get_overlapping_areas()
	for area in overlapping:
		if area in level_manager.sources:
			current_source = area
			if snap_on_drop:
				global_position = current_source.global_position
			return

	current_source = null
	if return_to_origin:
		global_position = original_position

# ════════════════════════════════════════════════════════════
# Selection Handling (called from LevelManager)
# ════════════════════════════════════════════════════════════

func set_selected(active: bool) -> void:
	_update_outline(active)

# ════════════════════════════════════════════════════════════
# Hover Effects
# ════════════════════════════════════════════════════════════

func _on_mouse_entered() -> void:
	_play_hover_scale_animation()

func _on_mouse_exited() -> void:
	_play_normal_scale_animation()

# ════════════════════════════════════════════════════════════
# Visual Feedback
# ════════════════════════════════════════════════════════════

func _update_outline(active: bool) -> void:
	outline_shader.material.set_shader_parameter("line_thickness", 4.0 if active else 1.0)

func _set_outline_color(c: Color) -> void:
	outline_shader.material.set_shader_parameter("line_color", c)

func _play_hover_scale_animation() -> void:
	create_tween().tween_property(sprite, "scale", Vector2(1.025, 1.025), 0.1)

func _play_normal_scale_animation() -> void:
	create_tween().tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.1)

func _play_click_scale_animation() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "scale", Vector2(1.05, 1.05), 0.08)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.08)

# ════════════════════════════════════════════════════════════
# Sound
# ════════════════════════════════════════════════════════════

func _play_click_sound() -> void:
	if sfx.stream:
		sfx.play()
