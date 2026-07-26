extends Node2D

const Card = preload("res://Scenes/card.tscn")
const Hero = preload("res://Scenes/hero.tscn")

@onready var hand_node: Node2D = $Hand
@onready var draw_pile_node: Node2D = $DrawPile
@onready var discard_pile_node: Node2D = $DiscardPile

@export var heroes: Array[Node2D] = []
@export var enemies: Array[Node2D] = []

const draw_count = 7

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

# Hero nodes in play this combat. Each node references its own HeroData
# (the persistent source of truth in Run.heroes), so there is no per-node stat
# copy to sync back — this is purely the per-combat view list.
var _hero_nodes: Array[Node2D] = []

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
	# HeroData was mutated live during combat, so there is nothing to write back.
	get_tree().change_scene_to_file("res://Scenes/rewards.tscn")

func game_over() -> void:
	get_tree().change_scene_to_file("res://Scenes/game_over.tscn")

func setup_enemies():
	for enemy in enemies:
		enemy.setup()

func setup_heroes() -> void:
	for i in Run.heroes.size():
		var hero = Hero.instantiate()
		hero.setup(Run.heroes[i])
		hero.position = HERO_POS[i]
		hero.scale = Vector2(0.8, 0.8)
		hero.connect("hero_clicked", _on_hero_clicked.bind(hero))
		add_child(hero)
		hero.set_action_available(true)
		_hero_nodes.append(hero)

func _on_hero_clicked(hero: Node2D) -> void:
	var card = hand_node.selected_card
	if card != null && hero.action_available && hero.abilities.has(card.suit):
		var ability = hero.abilities.get(card.suit)
		var discarded: Array[int] = [hand_node.discard(card).suit]
		discard_pile_node.place_on_top(discarded)
		print(ability.title)
		match(ability.target):
			"party":
				ability.effect.call(get_hero_nodes())
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
	for hero in _hero_nodes:
		if is_instance_valid(hero): # because Nodes can be pruned under us
			out.append(hero)
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
			var all_dead = clear_dead_heroes()
			if all_dead:
				game_over()
			discard_hand()
			enemies_select_actions()
			draw_for_turn()
			heroes_make_ready()

func heroes_make_ready():
	for hero in get_hero_nodes():
		hero.set_action_available(true)
		hero.status_effects = {}

# Enemies live in the real @export array, so removing them in place is correct.
func clear_dead(group: Array[Node2D]):
	for member in group.duplicate():
		if member.hp <= 0:
			var index = group.find(member)
			group.remove_at(index)
			member.queue_free()
	return group.size() == 0

# Heroes: prune the dead hero from Run.heroes (the source of truth) and from the
# per-combat view list, then free the node. Because the entry is removed from
# both places at once, nothing is left holding a reference to a freed node.
func clear_dead_heroes() -> bool:
	for hero in _hero_nodes.duplicate():
		if not is_instance_valid(hero) or hero.hp <= 0:
			if is_instance_valid(hero):
				Run.heroes.erase(hero.data)
				hero.queue_free()
			_hero_nodes.erase(hero)
	return _hero_nodes.is_empty()
