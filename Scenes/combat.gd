extends Node2D

const Card = preload("res://Scenes/card.tscn")

@onready var hand_node: Node2D = $Hand
@onready var draw_pile_node: Node2D = $DrawPile
@onready var discard_pile_node: Node2D = $DiscardPile

@export var heroes: Array[Node2D] = []
@export var enemies: Array[Node2D] = []

const draw_count = 5

var deck: Array[int] = [
	0, 0, 0, 0, 0,
	1, 1, 1, 1, 1,
	2, 2, 2, 2, 2,
]


func _ready() -> void:
	print(enemies.size())
	setup_enemies()
	setup_heroes()
	draw_pile_node.set_pile(deck.duplicate())
	draw_pile_node.shuffle()
	discard_pile_node.dump()
	enemies_select_actions()
	draw_for_turn()


func _unhandled_input(event: InputEvent) -> void:
	# TEMP: no enemies yet — press Enter/Space to "win" and go to rewards.
	# Replace with a real victory check later.
	if event.is_action_pressed("ui_accept"):
		win_combat()


func win_combat() -> void:
	get_tree().change_scene_to_file("res://Scenes/rewards.tscn")


func setup_enemies():
	for enemy in enemies:
		enemy.setup()

func setup_heroes():
	for hero in heroes:
		hero.set_hp(hero.max_hp)
		hero.set_action_available(true)
		hero.connect("hero_clicked", func():
			var card = hand_node.selected_card
			if card != null && hero.action_available && hero.abilities.has(card.suit):
				var ability = hero.abilities.get(card.suit)
				var discarded: Array[int] = [hand_node.discard(card)]
				discard_pile_node.place_on_top(discarded)
				print(ability.title)
				match(ability.target):
					"party":
						ability.effect.call(heroes)
					"enemies":
						ability.effect.call(enemies)
					"self":
						ability.effect.call(hero)
				hero.set_action_available(false)
				var all_dead = clear_dead(enemies)
				if all_dead:
					print("ROOM COMPLETE!") # TODO
				return
			print(hero.abilities) # TODO
		)

func enemies_select_actions():
	for enemy in enemies:
		enemy.choose_action()

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
	for enemy in enemies:
		enemy.take_action(heroes)

func discard_hand():
	discard_pile_node.place_on_top(hand_node.dump())


func _on_next_turn_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			enemies_take_actions()
			var all_dead = clear_dead(heroes)
			if all_dead:
				print("RUN FAILED.")
			# TODO: check for game over
			discard_hand()
			enemies_select_actions()
			draw_for_turn()
			heroes_make_ready()

func heroes_make_ready():
	for hero in heroes:
		hero.set_action_available(true)

func clear_dead(group: Array[Node2D]):
	for member in group.duplicate():
		if member.hp <= 0:
			var index = group.find(member)
			group.remove_at(index)
			member.queue_free()
	return group.size() == 0
