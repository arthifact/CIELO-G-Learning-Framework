# background.gd

extends TextureRect

var images := [
	"res://Menu/Home/Backgrounds/1.png",
	"res://Menu/Home/Backgrounds/2.png",
	"res://Menu/Home/Backgrounds/3.png"
]

func _ready() -> void:
	texture = load(images.pick_random())
