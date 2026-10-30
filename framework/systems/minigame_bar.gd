class_name MinigameBar
extends Control

signal check_requested

const FEEDBACK := {
	"invalid": ["Please select an option.", Color.BEIGE],
	"correct": ["Correct!", Color.LIGHT_GREEN],
	"wrong": ["Wrong!", Color.INDIAN_RED],
}

var _checked := false

@onready var _background: ColorRect = $ColorRect
@onready var _message: Label = $Label
@onready var _next_button: Button = $Next
@onready var _retry_button: Button = $Retry
@onready var _progress: Label = $Progress
@onready var _sounds := {
	"invalid": $AudioInvalid,
	"correct": $AudioCorrect,
	"wrong": $AudioWrong,
}


func _ready() -> void:
	_progress.text = ModuleManager.get_progress_text()
	_next_button.text = "Check"
	_retry_button.disabled = true
	_next_button.pressed.connect(_on_next_pressed)
	_retry_button.pressed.connect(_on_retry_pressed)


func show_invalid() -> void:
	_show_feedback("invalid")


func show_result(passed: bool) -> void:
	_checked = true
	_show_feedback("correct" if passed else "wrong")
	_next_button.text = "Next"
	_retry_button.disabled = passed


func _on_next_pressed() -> void:
	if not _checked:
		check_requested.emit()
		return
	_next_button.disabled = true
	_retry_button.disabled = true
	ModuleManager.play_next_minigame()


func _on_retry_pressed() -> void:
	_next_button.disabled = true
	_retry_button.disabled = true
	ModuleManager.retry()


func _show_feedback(kind: String) -> void:
	_message.text = FEEDBACK[kind][0]
	_background.color = FEEDBACK[kind][1]
	_sounds[kind].play()
