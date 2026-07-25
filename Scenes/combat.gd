extends Node2D

const Card = preload("res://Scenes/card.tscn")

@onready var hand: Node2D = $Hand

@onready var hero: Node2D = $Hero
@export var heroes: Array[Node2D] = [hero]

const draw_count = 5

var deck: Array[int] = [
	0, 0, 0, 0, 0,
	1, 1, 1, 1, 1,
	2, 2, 2, 2, 2,
]
var draw_pile: Array[int]
var discard_pile: Array[int] = []

### Turn Order
# Enemies select actions
# Player draws cards
#  - Reshuffle discard into deck if necessary
# Player assigns cards to heroes <- working on this step now
# Heroes take actions (actually, maybe this should happen as the cards are played?)
#  - If enemy has been defeated, go to rewards screen
# Enemies take actions
#  - If all heroes have been defeated, game over screen
# Player discards hand


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	draw_pile = deck.duplicate()
	draw_pile.shuffle()
	print(draw_pile)
	draw_for_turn()

func enemies_select_actions():
	pass

func draw_for_turn():
	var new_hand: Array[Node2D] = []
	for i in range(draw_count):
		var card = Card.instantiate()
		card.suit = draw_pile.pop_back()
		new_hand.push_back(card)
	hand.add_cards(new_hand)

func enemies_take_actions():
	pass

func discard_hand():
	pass
