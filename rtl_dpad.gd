extends Control

@onready var left: Button = $"Left"
@onready var right: Button = $"Right"

var is_arabic: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (TranslationServer.get_locale() == "ar") != is_arabic:
		is_arabic = !is_arabic
		swap_sides()


func swap_sides() -> void:
	var align := left.alignment
	var pos := left.position
	left.alignment = right.alignment
	right.alignment = align
	left.position = right.position
	right.position = pos
