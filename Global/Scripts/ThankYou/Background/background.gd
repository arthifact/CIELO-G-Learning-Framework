# background.gd

extends TextureRect

var images := [
	"res://Global/Scripts/ThankYou/Background/1.png",
	"res://Global/Scripts/ThankYou/Background/2.png",
	"res://Global/Scripts/ThankYou/Background/3.png",
	"res://Global/Scripts/ThankYou/Background/4.png",
	"res://Global/Scripts/ThankYou/Background/5.png"
]


func _ready() -> void:
	texture = load(images.pick_random())
