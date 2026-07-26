extends Node2D

const Card = preload("res://Scenes/card.tscn")
const Hero = preload("res://Scenes/hero.tscn")

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

const HERO_POS = [
	Vector2(380, 380),
	Vector2(550, 380),
	Vector2(720, 380),

	Vector2(380, 600),
	Vector2(550, 600),
	Vector2(720, 600),
]

var _hero_data: Array = []   # [{ Node2D, HeroData }] so we can write changes back

func _ready() -> void:
	print(enemies.size())
	setup_enemies()
	setup_heroes()
	draw_pile_node.set_pile(deck.duplicate())
	draw_pile_node.shuffle()
	discard_pile_node.dump()
	enemies_select_actions()
	draw_for_turn()

func win_combat() -> void:
	# TODO: alternate scene for graveyards
	for pair in _hero_data:
		pair.data.hp = pair.node.hp
	get_tree().change_scene_to_file("res://Scenes/rewards.tscn")

func game_over() -> void:
	get_tree().change_scene_to_file("res://Scenes/game_over.tscn")

func setup_enemies():
	for enemy in enemies:
		enemy.setup()

func setup_heroes() -> void:
	var i := 0
	for data in Run.heroes:
		var hero = Hero.instantiate()
		hero.hero_name = data.hero_name
		hero.age = data.age
		hero.max_hp = data.max_hp
		hero.hp = data.hp
		hero.position = HERO_POS[i]
		hero.scale = Vector2(0.8, 0.8)
		hero.connect("hero_clicked", func():
			var card = hand_node.selected_card
			if card != null && hero.action_available && hero.abilities.has(card.suit):
				var ability = hero.abilities.get(card.suit)
				var discarded: Array[int] = [hand_node.discard(card).suit]
				discard_pile_node.place_on_top(discarded)
				print(ability.title)
				match(ability.target):
					"party":
						ability.effect.call(_hero_data.map(func (pair): return pair.node))
					"enemies":
						ability.effect.call(enemies)
					"self":
						ability.effect.call(hero)
				hero.set_action_available(false)
				var all_dead = clear_dead(enemies)
				if all_dead:
					win_combat()
				return
			print(hero.abilities) # TODO
		)
		add_child(hero)
		hero.set_action_available(true)
		_hero_data.append({ "node": hero, "data": data })
		i = i + 1

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


func get_hero_nodes() -> Array[Node2D]:
	var out: Array[Node2D] = []
	for pair in _hero_data:
		out.append(pair["node"])
	return out


func enemies_take_actions():
	for enemy in enemies:
		enemy.take_action(get_hero_nodes())

func discard_hand():
	discard_pile_node.place_on_top(hand_node.dump())


func _on_next_turn_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			enemies_take_actions()
			var all_dead = clear_dead(get_hero_nodes())
			if all_dead:
				game_over()
			# TODO: check for game over
			discard_hand()
			enemies_select_actions()
			draw_for_turn()
			heroes_make_ready()

func heroes_make_ready():
	for hero in get_hero_nodes():
		hero.set_action_available(true)

func clear_dead(group: Array[Node2D]):
	for member in group.duplicate():
		if member.hp <= 0:
			var index = group.find(member)
			group.remove_at(index)
			member.queue_free()
	return group.size() == 0
