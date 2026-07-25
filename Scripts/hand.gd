extends Node2D

const Card = preload("res://Scenes/card.tscn")
var cards: Array[Node2D]
var selected_card

func add_cards(new_cards: Array[Node2D]):
	for card in new_cards:
		cards.push_front(card)
	_arange_cards()
	
func _arange_cards():
	for child in get_children():
		child.queue_free()
	
	var hand_size = cards.size();
	for i in range(hand_size):
		var card = cards[i]
		var lerp_weight = i / (hand_size - 1.)
		card.transform.origin = Vector2(lerp(-200, 200, lerp_weight), -100 * cos(lerp_angle(-0.6, 0.6, lerp_weight)) + 100);
		card.rotation = lerp_angle(-0.2, 0.2, lerp_weight);
		card.connect("card_selected", func(): _handle_card_selected(i))
		add_child(card)

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#var test_cards: Array[Node2D] = [
		#Card.instantiate(),
		#Card.instantiate(),
		#Card.instantiate(),
		#Card.instantiate(),
		#Card.instantiate(),
		#Card.instantiate(),
		#Card.instantiate(),
	#]
	#for card in test_cards:
		#card.suit = randi_range(0, 2)
	#add_cards(test_cards)

func _handle_card_selected(index: int):
	if selected_card != null: selected_card.deselect()
	selected_card = cards[index]
	print(selected_card)
	selected_card.select()
