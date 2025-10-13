extends Button
@onready var audio_invalid: AudioStreamPlayer2D = $"../AudioInvalid"
@onready var audio_wrong: AudioStreamPlayer2D = $"../AudioWrong"
@onready var audio_correct: AudioStreamPlayer2D = $"../AudioCorrect"

func play_feedback(result: String) -> void:
	match result:
		"correct":
			if audio_correct.stream:
				audio_correct.play()
		"wrong":
			if audio_wrong.stream:
				audio_wrong.play()
		"invalid":
			if audio_invalid.stream:
				audio_invalid.play()
