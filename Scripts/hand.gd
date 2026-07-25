extends Node2D

const Card = preload("res://Scenes/card.tscn")
var cards: Array[Node2D]
var selected_card

func add_cards(new_cards: Array[Node2D]):
	for card in new_cards:
		cards.push_front(card)
		add_child(card)
	_arange_cards()
	
func _arange_cards():
	var hand_size = cards.size();
	for i in range(hand_size):
		var card = cards[i]
		var lerp_weight = i / (hand_size - 1.) if hand_size > 1 else 0.5
		card.transform.origin = Vector2(lerp(-200, 200, lerp_weight), -100 * cos(lerp_angle(-0.6, 0.6, lerp_weight)) + 100);
		card.rotation = lerp_angle(-0.2, 0.2, lerp_weight);
		card.connect("card_selected", func(): _handle_card_selected(card))


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

func _handle_card_selected(card):
	if selected_card != null: selected_card.deselect()
	card.select()
	selected_card = card

func discard(card: Node2D):
	if selected_card == card:
		selected_card = null
	var index = cards.find(card)
	cards.remove_at(index)
	var suit = card.suit
	card.queue_free()
	_arange_cards()
	return suit

func dump():
	var pile: Array[int] = []
	for card in cards:
		pile.push_back(card.suit)
		card.queue_free()
	cards = []
	_arange_cards()
	return pile
