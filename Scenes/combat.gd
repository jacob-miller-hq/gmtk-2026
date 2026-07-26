extends Node2D

const Card = preload("res://Scenes/card.tscn")

@onready var hand_node: Node2D = $Hand
@onready var draw_pile_node: Node2D = $DrawPile
@onready var discard_pile_node: Node2D = $DiscardPile

@onready var hero: Node2D = $Hero
@export var heroes: Array[Node2D] = [hero]

const draw_count = 5

var deck: Array[int] = [
	0, 0, 0, 0, 0,
	1, 1, 1, 1, 1,
	2, 2, 2, 2, 2,
]


func _ready() -> void:
	# The fight starts right away — room choosing happens on the map screen.
	draw_pile_node.set_pile(deck.duplicate())
	draw_pile_node.shuffle()
	discard_pile_node.dump()
	draw_for_turn()


func _unhandled_input(event: InputEvent) -> void:
	# TEMP: no enemies yet — press Enter/Space to "win" and go to rewards.
	# Replace with a real victory check later.
	if event.is_action_pressed("ui_accept"):
		win_combat()


func win_combat() -> void:
	get_tree().change_scene_to_file("res://Scenes/rewards.tscn")


func enemies_select_actions():
	pass


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
	pass


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
