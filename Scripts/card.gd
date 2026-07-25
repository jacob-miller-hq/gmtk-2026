extends Node2D

signal card_selected

@onready var card: ColorRect = $ColorRect
@onready var selected_outline: ColorRect = $SelectedOutline
var suit: int = 0;
@export var card_colors: Array[Color] = [];

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# replace this with sprites?
	card.color = card_colors[suit]

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			emit_signal("card_selected");
			
func select():
	selected_outline.visible = true;
			
func deselect():
	selected_outline.visible = false;
	
