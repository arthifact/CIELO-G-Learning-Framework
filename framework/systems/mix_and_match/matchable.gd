class_name Matchable
extends InteractiveObject
# Lines are drawn from the Pivot child.

@export var max_outgoing := 1
@export var max_incoming := 1
# The objects a line from this one can go to.
@export var options: Array[Matchable] = []
# The objects this one should be connected to.
@export var answers: Array[Matchable] = []

@onready var pivot: Node2D = $Pivot
