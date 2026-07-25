extends Node2D

var array: Array[int];
@onready var label: Label = $Label
@onready var sprite_2d: Sprite2D = $Sprite2D

func set_pile(values: Array[int]):
	array = values.duplicate()
	update_count()
	
func shuffle():
	array.shuffle()

func draw_card():
	var drawn = array.pop_back()
	update_count()
	return drawn

func draw_cards(count: int = 1):
	var drawn: Array[int] = []
	for i in range(count):
		drawn.push_back(array.pop_back())
	update_count()
	return drawn

func place_on_top(cards: Array[int]):
	array.append_array(cards)
	update_count()

func place_on_bottom(cards: Array[int]):
	cards.append_array(array)
	array = cards

func size():
	return array.size()

func dump():
	var all_cards = array
	array = []
	update_count()
	return all_cards

func update_count():
	var count = array.size()
	sprite_2d.visible = false if count == 0 else true
	label.text = str(array.size())
