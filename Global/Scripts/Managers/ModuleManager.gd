# ModuleManager.gd
extends Node

# ════════════════════════════════════════════════════════════
# Config
# ════════════════════════════════════════════════════════════
const MENU_SCENE: String         = "res://Menu/Home/Home.tscn"
const EXPLANATION_SCENE: String  = "res://Module/Learn/ExplanationSystem.tscn"
const CERTIFICATE_SCENE: String  = "res://Global/Scripts/SetName/set_name.tscn"
const THANK_YOU_SCENE: String    = "res://Global/Scripts/ThankYou/thank_you.tscn"

# ════════════════════════════════════════════════════════════
# START EDIT HERE
# ════════════════════════════════════════════════════════════

const MINIGAMES: Array[String] = [
	# Mini-games go here as string path e.g:
	#"res://Module/Play/Minigame_1/minigame_1.tscn"
	
]

# ════════════════════════════════════════════════════════════
# END EDIT HERE
# ════════════════════════════════════════════════════════════

# ════════════════════════════════════════════════════════════
# State
# ════════════════════════════════════════════════════════════
var _queue: Array[String] = []     # remaining unique minigames, shuffled
var _last: String = ""             # current scene path
var _player_name: String = ""      # player’s name

# Tracking attempts/results
var _attempts: Dictionary = {}     # scene_path -> attempts count (first Check = 1)
var _used_retry: bool = false      # any retry pressed across run?
var _first_try_successes: int = 0  # how many were passed on the very first attempt
var _completed: int = 0            # how many minigames finished (passed & moved on)

func _ready() -> void:
	randomize()

# ════════════════════════════════════════════════════════════
# Public API
# ════════════════════════════════════════════════════════════
func set_player_name(player_name: String) -> void:
	_player_name = player_name

func get_player_name() -> String:
	return _player_name

func start_explanation() -> void:
	_change(EXPLANATION_SCENE)

func start_games() -> void:
	# reset run state
	_queue = MINIGAMES.duplicate()
	_queue.shuffle()
	_last = ""
	_attempts.clear()
	_used_retry = false
	_first_try_successes = 0
	_completed = 0
	_play_next()

func go_menu() -> void:
	_change(MENU_SCENE)

# Minigames should call this exactly once
# If `passed` is true
func submit_minigame_result(passed: bool) -> void:
	if _last == "":
		return
	# Count this attempt
	if not _attempts.has(_last):
		_attempts[_last] = 0
	_attempts[_last] += 1

	var attempt_num: int = int(_attempts[_last])

	# First attempt outcome
	if attempt_num == 1 and passed:
		_first_try_successes += 1

# Called on "Next" (after correct).
func play_next_minigame() -> void:
	_completed += 1
	_play_next()

# Called on "Retry": reload current scene (disqualifies certificate).
func retry() -> void:
	_used_retry = true
	if _last != "":
		_change(_last)

func get_progress_text() -> String:
	var total: int = MINIGAMES.size()
	var current: int
	if _last == "" or not MINIGAMES.has(_last):
		current = 0
	else:
		current = total - _queue.size()
	return "%d / %d" % [current, total]

# ════════════════════════════════════════════════════════════
# Internals
# ════════════════════════════════════════════════════════════
func _play_next() -> void:
	# If finished all minigames, decide destination
	if _queue.is_empty():
		_finish_run()
		return

	_last = _queue.pop_front()
	# reset attempt counter for this minigame scene
	_attempts[_last] = 0
	_change(_last)

func _finish_run() -> void:
	var total: int = MINIGAMES.size()
	var perfect_run: bool = (_first_try_successes == total) and (not _used_retry)
	if perfect_run:
		_change(CERTIFICATE_SCENE)
	else:
		_change(THANK_YOU_SCENE)

func _change(path: String) -> void:
	SceneTransition.change_scene(path)
