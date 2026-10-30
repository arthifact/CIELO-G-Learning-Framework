extends Node

const MENU_SCENE := "res://framework/menu/home.tscn"
const EXPLANATION_SCENE := "res://framework/learn/explanation.tscn"
const NAME_ENTRY_SCENE := "res://framework/finish/name_entry.tscn"
const CERTIFICATE_SCENE := "res://framework/finish/certificate.tscn"
const THANK_YOU_SCENE := "res://framework/finish/thank_you.tscn"

var player_name := ""

var _queue: Array[String] = []
var _played := 0
var _perfect_run := true


func go_menu() -> void:
	_change(MENU_SCENE)


func start_explanation() -> void:
	_change(EXPLANATION_SCENE)


func start_games() -> void:
	if SceneTransition.busy:
		return
	_queue = Module.MINIGAMES.duplicate()
	_queue.shuffle()
	_played = 0
	_perfect_run = true
	play_next_minigame()


func play_next_minigame() -> void:
	if SceneTransition.busy:
		return
	if _queue.is_empty():
		_change(NAME_ENTRY_SCENE if _perfect_run else THANK_YOU_SCENE)
		return
	_played += 1
	_change(_queue.pop_front())


func retry() -> void:
	_change(get_tree().current_scene.scene_file_path)


func show_certificate() -> void:
	_change(CERTIFICATE_SCENE)


# A certificate needs every minigame passed on the first try.
func submit_minigame_result(passed: bool) -> void:
	if not passed:
		_perfect_run = false


func get_progress_text() -> String:
	return "%d / %d" % [_played, Module.MINIGAMES.size()]


func _change(path: String) -> void:
	SceneTransition.change_scene(path)
