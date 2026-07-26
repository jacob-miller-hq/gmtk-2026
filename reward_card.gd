extends Node2D

signal card_selected

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var label: Label = $Sprite2D/Label

var v: int

func set_value(value: int):
	if value > 0: value *= -1
	v = value
	if label:
		label.text = str(value)

func _ready():
	label.text = str(v)

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			emit_signal("card_selected");
			
func select():
	sprite_2d.scale *= 1.5
	transform.origin += Vector2(0, -20)
	z_index = 1

func deselect():
	sprite_2d.scale /= 1.5
	transform.origin += Vector2(0, 20)
	z_index = 0
