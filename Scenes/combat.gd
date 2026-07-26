extends Node2D

const Card = preload("res://Scenes/card.tscn")

@onready var hand_node: Node2D = $Hand
@onready var draw_pile_node: Node2D = $DrawPile
@onready var discard_pile_node: Node2D = $DiscardPile
@onready var hero: Node2D = $Hero

@export var heroes: Array[Node2D] = []

const draw_count = 5

var deck: Array[int] = [
	0, 0, 0, 0, 0,
	1, 1, 1, 1, 1,
	2, 2, 2, 2, 2,
]
#var draw_pile: Array[int]
#var discard_pile: Array[int] = []

### Turn Order
# Enemies select actions
# Draw for turn
#  - Reshuffle discard into deck if necessary
# Player assigns cards to heroes <- working on this step now
# Heroes take actions (actually, maybe this should happen as the cards are played?)
#  - If enemy has been defeated, go to rewards screen
# Player press [End Turn]
# Enemies take actions
#  - If all heroes have been defeated, game over screen
# Discard hand

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_heroes()
	draw_pile_node.set_pile(deck.duplicate())
	draw_pile_node.shuffle()
	discard_pile_node.dump()
	draw_for_turn()

func _unhandled_input(event: InputEvent) -> void:
	## TODO: Replace with real victory condition
	if event.is_action_pressed("ui_accept"):
		win_combat()

func setup_heroes():
	# TODO: these should probably be instantiated here
	for hero in heroes:
		print(hero.hero_name)
		hero.set_hp(hero.max_hp)
		hero.set_action_available(true)
		hero.connect("hero_clicked", func():
			var card = hand_node.selected_card
			if card != null && hero.action_available && hero.abilities.has(card.suit):
				var ability = hero.abilities.get(card.suit)
				var discarded: Array[int] = [hand_node.discard(card)]
				discard_pile_node.place_on_top(discarded)
				print(ability.title)
				hero.set_action_available(false)
				return
			print(hero.abilities) # TODO
		)

func enemies_select_actions():
	print("Enemy will attack")
	pass # TODO

func draw_for_turn():
	var new_hand: Array[Node2D] = []
	for i in range(draw_count):
		var card = Card.instantiate()
		if draw_pile_node.size() == 0:
			# empty discard pile and shuffle
			draw_pile_node.set_pile(discard_pile_node.dump())
			draw_pile_node.shuffle()
		card.suit = draw_pile_node.draw_card()
		new_hand.push_back(card)
	hand_node.add_cards(new_hand)

func enemies_take_actions():
	print("Enemy attack")
	pass # TODO

func discard_hand():
	discard_pile_node.place_on_top(hand_node.dump())

func _on_next_turn_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			enemies_take_actions()
			# TODO: check for game over
			discard_hand()
			enemies_select_actions()
			draw_for_turn()
			heroes_make_ready()

func heroes_make_ready():
	for hero in heroes:
		hero.set_action_available(true)


## Move to Rewards screen
func win_combat() -> void:
	get_tree().change_scene_to_file("res://Scenes/rewards.tscn")
