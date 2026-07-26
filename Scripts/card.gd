extends Node2D

signal card_selected

@onready var sprite_2d: Sprite2D = $Sprite2D
var suit: int = 0;
@export var card_textures: Array[Texture] = [];

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# replace this with sprites?
	sprite_2d.texture = card_textures[suit]

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			print("card pressed")
			emit_signal("card_selected");
			
func select():
	sprite_2d.scale *= 1.5
	transform.origin += Vector2(0, -20)
	z_index = 1

func deselect():
	sprite_2d.scale /= 1.5
	transform.origin += Vector2(0, 20)
	z_index = 0
